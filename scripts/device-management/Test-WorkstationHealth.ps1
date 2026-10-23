<#
.SYNOPSIS
Runs the shared deployment checks as a workstation health assessment.
.DESCRIPTION
Reads configuration and writes private JSON/logs. No repairs or configuration changes.
Uses the deployment validator so health and deployment criteria remain consistent.
Requires Windows and read access to CIM, registry and event providers.
.EXAMPLE
./Test-WorkstationHealth.ps1 -ExpectedName WS01 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9-]{1,15}$')][string]$ExpectedName,
    [ValidatePattern('^[A-Za-z0-9.-]+$')][string]$ExpectedDomain = 'corp.example.test',
    [string]$OutputPath = './outputs/health.json',
    [string]$LogPath = './outputs/health.log',
    [switch]$Overwrite
)
$ErrorActionPreference = 'Stop'
& "$PSScriptRoot/../imaging/Test-LabDeployment.ps1" -ExpectedName $ExpectedName -ExpectedDomain $ExpectedDomain -OutputPath $OutputPath -LogPath $LogPath -Overwrite:$Overwrite -WhatIf:$WhatIfPreference
