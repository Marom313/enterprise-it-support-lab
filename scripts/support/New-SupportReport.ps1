<#
.SYNOPSIS
Converts a deployment or health JSON report into a plain Markdown support report.
.DESCRIPTION
Reads one report, validates its checks and writes a new local Markdown file.
Escapes Markdown and HTML in fields. No network requests or system changes occur.
Review identifiers before sharing. Existing files are not overwritten by default.
.EXAMPLE
./New-SupportReport.ps1 -InputPath ./sample-data/deployment-example.json
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})][string]$InputPath,
    [string]$OutputPath = './outputs/support-report.md',
    [string]$LogPath = './outputs/support-report.log',
    [switch]$Overwrite
)
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
function ConvertTo-SafeCell {
    param([AllowNull()][object]$Value)
    [System.Net.WebUtility]::HtmlEncode(([string]$Value -replace '[\r\n]+',' ')) -replace '\|','&#124;' -replace '`','&#96;'
}
try {
    $report = Get-Content -LiteralPath $InputPath -Raw | ConvertFrom-Json
    if (-not $report.ComputerName -or -not $report.Checks) { throw 'Expected ComputerName and nonempty Checks.' }
    $lines = @('# Support report', '', ('Device: ' + (ConvertTo-SafeCell $report.ComputerName)), '', '| Check | Status | Detail |', '| --- | --- | --- |')
    foreach ($check in $report.Checks) {
        if (-not $check.Name -or $check.Status -notin @('Pass','Fail','Review','Unknown')) { throw 'Invalid check record.' }
        $lines += '| {0} | {1} | {2} |' -f (ConvertTo-SafeCell $check.Name),(ConvertTo-SafeCell $check.Status),(ConvertTo-SafeCell $check.Detail)
    }
    if ((Test-Path -LiteralPath $OutputPath) -and -not $Overwrite) { throw 'Output exists; choose another path or use -Overwrite.' }
    if ($PSCmdlet.ShouldProcess($OutputPath, 'Write support Markdown')) {
        $parent = Split-Path -Parent $OutputPath
        if ($parent) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
        $lines | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    }
    Write-LabLog -Message "Support report completed; WhatIf=$WhatIfPreference" -Path $LogPath
} catch {
    Write-LabLog -Message 'Support report failed; inspect locally' -Path $LogPath
    throw
}
