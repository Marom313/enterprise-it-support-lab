<#
.SYNOPSIS
Collects local Windows inventory into private JSON without changing configuration.
.DESCRIPTION
Reads CIM and uninstall registry keys; avoids Win32_Product and activation keys.
Writes JSON and a minimal activity log. Output includes user and device identifiers:
sanitize before sharing. Installed software is limited to machine-wide entries.
.EXAMPLE
./Get-LabInventory.ps1 -OutputPath ./outputs/WS01-inventory.json
.EXAMPLE
./Get-LabInventory.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateNotNullOrEmpty()][string]$OutputPath = './outputs/inventory.json',
    [ValidateNotNullOrEmpty()][string]$LogPath = './outputs/inventory.log',
    [switch]$Overwrite
)
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
try {
    Assert-LabWindows
    $os = Get-CimInstance Win32_OperatingSystem
    $system = Get-CimInstance Win32_ComputerSystem
    $software = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } | Select-Object DisplayName,DisplayVersion,Publisher | Sort-Object DisplayName -Unique)
    $data = [ordered]@{
        CollectedAt = (Get-Date).ToUniversalTime().ToString('o')
        ComputerName = $env:COMPUTERNAME
        LoggedInUser = $system.UserName
        OperatingSystem = $os.Caption
        OSVersion = $os.Version
        CPU = @(Get-CimInstance Win32_Processor | Select-Object Name,NumberOfCores)
        RAMGB = [math]::Round($system.TotalPhysicalMemory / 1GB, 2)
        Disks = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID,@{ n='SizeGB'; e={[math]::Round($_.Size / 1GB,2)} },@{ n='FreeGB'; e={[math]::Round($_.FreeSpace / 1GB,2)} })
        IPAddresses = @(Get-NetIPAddress -AddressFamily IPv4 | Select-Object InterfaceAlias,IPAddress)
        InstalledSoftware = $software
        LastBootTime = $os.LastBootUpTime.ToUniversalTime().ToString('o')
    }
    Export-LabJson -Data $data -Path $OutputPath -Overwrite:$Overwrite -WhatIf:$WhatIfPreference
    Write-LabLog -Message "Inventory collected; WhatIf=$WhatIfPreference" -Path $LogPath
} catch {
    Write-LabLog -Message 'Inventory failed; inspect locally' -Path $LogPath
    throw
}
