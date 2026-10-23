<#
.SYNOPSIS
Reports post-deployment readiness without repairing or configuring Windows.
.DESCRIPTION
Checks activation state without keys, name, domain, DNS, TCP, system disk,
services, machine-wide applications, update history/reboot state, and recent
System/Application error counts. Each check records Pass, Fail, Review or Unknown.
Update history is evidence only: this script does not scan for missing updates.
Writes JSON and logs. Failing checks require operator review; no remediation runs.
Use -FailOnFinding in acceptance pipelines. WhatIf skips all collection.
.EXAMPLE
./Test-LabDeployment.ps1 -ExpectedName WS01 -ExpectedDomain corp.example.test
.EXAMPLE
./Test-LabDeployment.ps1 -ExpectedName WS01 -WhatIf
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification='Parameters are consumed by synchronous probe scriptblocks invoked by Add-Check; analyzer does not follow those references.')]
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9-]{1,15}$')][string]$ExpectedName,
    [ValidatePattern('^[A-Za-z0-9.-]+$')][string]$ExpectedDomain = 'corp.example.test',
    [ValidatePattern('^[A-Za-z0-9.-]+$')][string]$DnsName = 'DC01.corp.example.test',
    [ValidatePattern('^[A-Za-z0-9.-]+$')][string]$ConnectivityTarget = 'DC01.corp.example.test',
    [ValidateRange(1,65535)][int]$ConnectivityPort = 53,
    [ValidateRange(1,1000)][int]$MinimumFreeGB = 20,
    [ValidateNotNullOrEmpty()][string[]]$RequiredServices = @('Dnscache','EventLog','Winmgmt'),
    [ValidateNotNullOrEmpty()][string[]]$RequiredApplications = @('7-Zip'),
    [ValidateRange(1,168)][int]$EventHours = 24,
    [string]$OutputPath = './outputs/deployment.json',
    [string]$LogPath = './outputs/deployment.log',
    [switch]$FailOnFinding,
    [switch]$Overwrite
)
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
$checks = New-Object 'System.Collections.Generic.List[object]'
function Add-Check {
    param([string]$Name, [scriptblock]$Probe)
    try {
        $finding = & $Probe
        $checks.Add([pscustomobject]@{ Name=$Name; Status=$finding.Status; Detail=$finding.Detail })
    } catch {
        $checks.Add([pscustomobject]@{ Name=$Name; Status='Unknown'; Detail='Probe unavailable; inspect permissions and provider locally.' })
    }
}
try {
    Assert-LabWindows
    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, 'Read deployment acceptance state')) {
        Add-Check 'ComputerName' { @{ Status=$(if ($env:COMPUTERNAME -eq $ExpectedName) {'Pass'} else {'Fail'}); Detail=$env:COMPUTERNAME } }
        Add-Check 'DomainMembership' {
            $system = Get-CimInstance Win32_ComputerSystem
            @{ Status=$(if ($system.PartOfDomain -and $system.Domain -eq $ExpectedDomain) {'Pass'} else {'Fail'}); Detail=$system.Domain }
        }
        Add-Check 'Activation' {
            $licenses = @(Get-CimInstance SoftwareLicensingProduct -Filter "ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f' AND LicenseStatus=1")
            @{ Status=$(if ($licenses.Count -gt 0) {'Pass'} else {'Fail'}); Detail='Licensed Windows product detected: ' + ($licenses.Count -gt 0) }
        }
        Add-Check 'DNS' { $null = Resolve-DnsName $DnsName -ErrorAction Stop; @{Status='Pass'; Detail='Configured resolver returned an answer'} }
        Add-Check 'Connectivity' {
            $ok = Test-NetConnection $ConnectivityTarget -Port $ConnectivityPort -InformationLevel Quiet -WarningAction SilentlyContinue
            @{Status=$(if ($ok) {'Pass'} else {'Fail'}); Detail="TCP $ConnectivityPort to configured target"}
        }
        Add-Check 'SystemDisk' {
            $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'"
            if (-not $disk) { throw 'System volume unavailable' }
            $free = [math]::Round($disk.FreeSpace / 1GB,2)
            @{Status=$(if ($free -ge $MinimumFreeGB) {'Pass'} else {'Fail'}); Detail="$free GB free"}
        }
        foreach ($name in $RequiredServices) {
            Add-Check "Service:$name" { $service = Get-Service -Name $name -ErrorAction Stop; @{Status=$(if ($service.Status -eq 'Running') {'Pass'} else {'Fail'}); Detail=[string]$service.Status} }
        }
        $apps = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName} | Select-Object -ExpandProperty DisplayName)
        foreach ($name in $RequiredApplications) {
            Add-Check "Application:$name" { @{Status=$(if (@($apps | Where-Object {$_ -like "*$name*"}).Count -gt 0) {'Pass'} else {'Fail'}); Detail='Machine-wide uninstall registry match only; verify launch and version separately'} }
        }
        Add-Check 'WindowsUpdateEvidence' {
            $latest = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1
            if (-not $latest) { throw 'No update history' }
            $pending = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') -or (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending')
            @{Status='Review'; Detail="Latest hotfix: $($latest.HotFixID); installed: $($latest.InstalledOn); pending reboot: $pending; run approved update scan manually"}
        }
        foreach ($channel in @('System','Application')) {
            Add-Check "Events:$channel" {
                # Enumerate a bounded window; permission/provider failures remain Unknown.
                $events = @(Get-WinEvent -LogName $channel -MaxEvents 1000 -ErrorAction Stop | Where-Object {$_.TimeCreated -ge (Get-Date).AddHours(-$EventHours) -and $_.Level -in @(1,2)})
                @{Status=$(if ($events.Count -eq 0) {'Pass'} else {'Review'}); Detail="$($events.Count) critical/error events in last $EventHours hours within newest 1000 records; messages excluded"}
            }
        }
        $report = @{ SchemaVersion=1; ComputerName=$env:COMPUTERNAME; CollectedAt=(Get-Date).ToUniversalTime().ToString('o'); Checks=@($checks.ToArray()) }
        Export-LabJson -Data $report -Path $OutputPath -Overwrite:$Overwrite
        Write-LabLog -Message 'Deployment checks completed; review JSON findings' -Path $LogPath
        if ($FailOnFinding -and @($checks | Where-Object {$_.Status -ne 'Pass'}).Count -gt 0) { throw 'Acceptance has non-Pass findings; review report.' }
    } else { Write-LabLog -Message 'Deployment collection skipped by WhatIf or confirmation' -Path $LogPath }
} catch {
    Write-LabLog -Message 'Deployment validation failed or acceptance findings remain; inspect locally' -Path $LogPath
    throw
}
