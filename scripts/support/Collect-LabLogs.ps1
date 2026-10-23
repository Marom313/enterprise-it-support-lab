<#
.SYNOPSIS
Collects a bounded set of Windows event metadata without event messages.
.DESCRIPTION
Reads Application and System logs only. Exports private JSON and a minimal log;
does not clear logs, collect Security logs, or send data anywhere. Review output
for identifiers before sharing. Requires permission to read selected channels.
.EXAMPLE
./Collect-LabLogs.ps1 -Hours 4 -MaxEvents 100
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateRange(1,168)][int]$Hours = 24,
    [ValidateRange(1,1000)][int]$MaxEvents = 100,
    [string]$OutputPath = './outputs/events.json',
    [string]$LogPath = './outputs/events.log',
    [switch]$Overwrite
)
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
try {
    Assert-LabWindows
    if ($PSCmdlet.ShouldProcess('System and Application logs', 'Collect bounded event metadata')) {
        $data = foreach ($channel in @('System','Application')) {
            Get-WinEvent -LogName $channel -MaxEvents $MaxEvents -ErrorAction Stop |
                Where-Object {$_.TimeCreated -ge (Get-Date).AddHours(-$Hours)} |
                Select-Object TimeCreated,Id,LevelDisplayName,ProviderName,LogName
        }
        Export-LabJson -Data @($data) -Path $OutputPath -Overwrite:$Overwrite
    }
    Write-LabLog -Message "Event collection completed; WhatIf=$WhatIfPreference" -Path $LogPath
} catch {
    Write-LabLog -Message 'Event collection failed; inspect locally' -Path $LogPath
    throw
}
