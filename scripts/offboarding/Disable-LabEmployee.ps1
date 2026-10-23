<#
.SYNOPSIS
Disables a lab user and removes only the two managed role groups.
.DESCRIPTION
Delegates mutations, input validation, scope checks, error handling and logging to
Invoke-LabDirectory.ps1. Requires RSAT, explicit DC and delegated lab rights.
WhatIf is forwarded. Onboarding does not grant application access or allocate assets;
offboarding does not revoke cloud sessions. Complete the corresponding ITSM checklist.
.EXAMPLE
./Disable-LabEmployee.ps1 -Server DC01.corp.example.test -Identity alex.river -WhatIf
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
param(
    [Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9.-]{1,19}$')][string]$Identity,
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9.-]+$')][string]$Server,
    [ValidatePattern('^DC=[A-Za-z0-9-]+(,DC=[A-Za-z0-9-]+)+$')][string]$BaseDN = 'DC=corp,DC=example,DC=test',
    [string]$LogPath = './outputs/directory.log'
)
$ErrorActionPreference = 'Stop'
# The delegate owns ShouldProcess for every mutation and writes failure logs.
& "$PSScriptRoot/../active-directory/Invoke-LabDirectory.ps1" -Action Disable -Identity $Identity -Server $Server -BaseDN $BaseDN -LogPath $LogPath -WhatIf:$WhatIfPreference
