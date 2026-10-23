<#
.SYNOPSIS
Validates the whole CSV batch before provisioning lab accounts.
.DESCRIPTION
Delegates mutations, input validation, scope checks, error handling and logging to
Invoke-LabDirectory.ps1. Requires RSAT, explicit DC and delegated lab rights.
WhatIf is forwarded. Onboarding does not grant application access or allocate assets;
offboarding does not revoke cloud sessions. Complete the corresponding ITSM checklist.
.EXAMPLE
./Import-LabUsers.ps1 -Server DC01.corp.example.test -CsvPath ./sample-data/users.csv -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    [Parameter(Mandatory)][ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})][string]$CsvPath,
    [Security.SecureString]$InitialPassword,
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9.-]+$')][string]$Server,
    [ValidatePattern('^DC=[A-Za-z0-9-]+(,DC=[A-Za-z0-9-]+)+$')][string]$BaseDN = 'DC=corp,DC=example,DC=test',
    [string]$LogPath = './outputs/directory.log'
)
$ErrorActionPreference = 'Stop'
# The delegate owns ShouldProcess for every mutation and writes failure logs.
& "$PSScriptRoot/./Invoke-LabDirectory.ps1" -Action ImportUsers -CsvPath $CsvPath -InitialPassword $InitialPassword -Server $Server -BaseDN $BaseDN -LogPath $LogPath -WhatIf:$WhatIfPreference
