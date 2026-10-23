<#
.SYNOPSIS
Creates or updates one narrowly scoped computer screen-lock GPO.
.DESCRIPTION
Sets the machine inactivity timeout to 900 seconds and links it to the lab
Computers OU. Requires GroupPolicy RSAT and delegated GPO create/edit/link rights.
Rejects an existing policy linked outside this OU. WhatIf makes no GPO changes.
Does not change the domain password policy or preferences. Logs operation status.
.EXAMPLE
./Set-LabGpo.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    [ValidatePattern('^[A-Za-z0-9.-]+\.test$')][string]$Domain = 'corp.example.test',
    [ValidatePattern('^OU=Computers,OU=Lab,DC=[A-Za-z0-9-]+(,DC=[A-Za-z0-9-]+)+$')][string]$TargetOU = 'OU=Computers,OU=Lab,DC=corp,DC=example,DC=test',
    [ValidateRange(60,3600)][int]$InactivitySeconds = 900,
    [string]$LogPath = './outputs/gpo.log'
)
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
try {
    Assert-LabWindows
    Import-Module GroupPolicy -ErrorAction Stop
    $dnDomain = (($TargetOU -split ',') | Where-Object {$_ -like 'DC=*'}) -replace '^DC=', ''
    if (($dnDomain -join '.') -ne $Domain) { throw 'Target OU and domain differ.' }
    $name = 'LAB-Computer-ScreenLock'
    $gpo = @(Get-GPO -All -Domain $Domain | Where-Object DisplayName -eq $name)
    if ($gpo.Count -gt 1) { throw 'Duplicate GPO names require manual review.' }
    if ($gpo.Count -eq 1) {
        [xml]$report = Get-GPOReport -Guid $gpo[0].Id -Domain $Domain -ReportType Xml
        $links = @($report.SelectNodes("//*[local-name()='LinksTo']/*[local-name()='SOMPath']"))
        $expectedPath = "$Domain/Lab/Computers"
        foreach ($link in $links) { if ($link.InnerText -ne $expectedPath) { throw 'Existing GPO linked outside target; review manually.' } }
    }
    if ($PSCmdlet.ShouldProcess("$Domain : $TargetOU", "Set $name machine inactivity timeout")) {
        if ($gpo.Count -eq 0) { $policy = New-GPO -Name $name -Domain $Domain } else { $policy = $gpo[0] }
        Set-GPRegistryValue -Guid $policy.Id -Domain $Domain -Key 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System' -ValueName InactivityTimeoutSecs -Type DWord -Value $InactivitySeconds | Out-Null
        $inherited = Get-GPInheritance -Target $TargetOU -Domain $Domain
        if ($policy.Id -notin @($inherited.GpoLinks | Select-Object -ExpandProperty GpoId)) {
            New-GPLink -Guid $policy.Id -Target $TargetOU -Domain $Domain -LinkEnabled Yes | Out-Null
        }
    }
    Write-LabLog -Message "Screen-lock GPO completed; WhatIf=$WhatIfPreference" -Path $LogPath
} catch {
    Write-LabLog -Message 'GPO operation failed; inspect policy and links before retrying' -Path $LogPath
    throw
}
