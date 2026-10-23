<#
.SYNOPSIS
Joins a workstation to the fictional lab domain without automatically rebooting.
.DESCRIPTION
Changes local domain membership; requires local admin and delegated join credentials.
Creates the computer object in the lab Computers OU. Reboot manually after review.
WhatIf performs no join and never prompts for credentials. Failures are logged.
.EXAMPLE
./Join-LabDomain.ps1 -WhatIf
.EXAMPLE
./Join-LabDomain.ps1 -Credential (Get-Credential)
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [ValidatePattern('^[A-Za-z0-9.-]+\.test$')][string]$Domain = 'corp.example.test',
    [ValidatePattern('^OU=Computers,OU=Lab,DC=[A-Za-z0-9-]+(,DC=[A-Za-z0-9-]+)+$')][string]$OUPath = 'OU=Computers,OU=Lab,DC=corp,DC=example,DC=test',
    [PSCredential]$Credential,
    [string]$LogPath = './outputs/domain-join.log'
)
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
try {
    Assert-LabWindows
    $dnDomain = (($OUPath -split ',') | Where-Object { $_ -like 'DC=*' }) -replace '^DC=', ''
    if (($dnDomain -join '.') -ne $Domain) { throw 'OU domain and requested domain differ.' }
    if ((Get-CimInstance Win32_ComputerSystem).PartOfDomain) { throw 'Already domain joined; migration is not supported.' }
    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Join $Domain in $OUPath; manual reboot required")) {
        if (-not $Credential) { throw 'Supply Credential using Get-Credential.' }
        Add-Computer -DomainName $Domain -OUPath $OUPath -Credential $Credential -PassThru -ErrorAction Stop
    }
    Write-LabLog -Message "Domain join completed; WhatIf=$WhatIfPreference; verify after reboot" -Path $LogPath
} catch {
    Write-LabLog -Message 'Domain join failed; inspect locally' -Path $LogPath
    throw
}
