<#
.SYNOPSIS
Runs isolated report, overwrite and WhatIf regression checks without AD access.
.DESCRIPTION
Creates and removes only an owned temporary directory. Imports the common module
and exercises local output; never probes a network or changes operating system state.
.EXAMPLE
./tests/Test-Behavior.ps1
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$temp = Join-Path ([IO.Path]::GetTempPath()) ('itlab-test-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $temp | Out-Null
try {
    Import-Module "$root/scripts/common/Lab.Common.psm1" -Force
    $json = Join-Path $temp 'example.json'
    Export-LabJson -Data @{ Value=1 } -Path $json -WhatIf
    if (Test-Path $json) { throw 'WhatIf unexpectedly wrote JSON.' }
    Export-LabJson -Data @{ Value=1 } -Path $json
    $rejected = $false
    try { Export-LabJson -Data @{ Value=2 } -Path $json } catch { $rejected = $true }
    if (-not $rejected) { throw 'Overwrite must be rejected by default.' }
    if ((Get-Content $json -Raw | ConvertFrom-Json).Value -ne 1) { throw 'Original data changed.' }
    $report = Join-Path $temp 'report.md'
    $log = Join-Path $temp 'activity.log'
    & "$root/scripts/support/New-SupportReport.ps1" -InputPath "$root/sample-data/deployment-example.json" -OutputPath $report -LogPath $log -WhatIf
    if (Test-Path $report) { throw 'Report WhatIf wrote output.' }
    & "$root/scripts/support/New-SupportReport.ps1" -InputPath "$root/sample-data/deployment-example.json" -OutputPath $report -LogPath $log
    if ((Get-Content $report -Raw) -notmatch 'DomainMembership \| Fail') { throw 'Report dropped a failure finding.' }
    $malicious = Join-Path $temp 'malformed.json'
    Set-Content -LiteralPath $malicious -Value '{"ComputerName":"WS01","Checks":[{"Name":"x","Status":"Invented","Detail":"x"}]}'
    $rejected = $false
    try { & "$root/scripts/support/New-SupportReport.ps1" -InputPath $malicious -OutputPath (Join-Path $temp 'invalid.md') -LogPath $log } catch { $rejected = $true }
    if (-not $rejected) { throw 'Invalid status accepted.' }
    Write-Output 'PASS: JSON WhatIf, overwrite protection, report WhatIf, failure preservation and malformed-report rejection.'
} finally {
    $resolved = [IO.Path]::GetFullPath($temp)
    $expectedParent = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    if (-not $resolved.StartsWith($expectedParent, [StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolved -Leaf) -notlike 'itlab-test-*') { throw 'Unsafe test cleanup target.' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
