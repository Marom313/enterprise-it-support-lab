<#
.SYNOPSIS
Parses repository PowerShell/XML and runs PSScriptAnalyzer; no lab changes.
.DESCRIPTION
Fails on parser errors, malformed XML and analyzer warnings/errors. Requires
PSScriptAnalyzer 1.24.0 installed or supplied via ModulePath. Reads files only.
.EXAMPLE
./tests/Test-PowerShell.ps1 -ModulePath ./outputs/modules/PSScriptAnalyzer/1.24.0/PSScriptAnalyzer.psd1
#>
[CmdletBinding()]
param([ValidateNotNullOrEmpty()][string]$ModulePath = 'PSScriptAnalyzer')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$files = @(Get-ChildItem "$root/scripts","$root/tests" -Recurse -File | Where-Object {$_.Extension -in @('.ps1','.psm1','.psd1')})
$failed = $false
foreach ($file in $files) {
    $tokens = $null
    $parseErrors = $null
    $null = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$parseErrors)
    if ($parseErrors.Count -gt 0) { $parseErrors | Write-Output; $failed = $true }
}
foreach ($file in Get-ChildItem "$root/scripts" -Recurse -Filter *.xml) {
    $settings = New-Object System.Xml.XmlReaderSettings
    $settings.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $settings.XmlResolver = $null
    $reader = [System.Xml.XmlReader]::Create($file.FullName, $settings)
    try { while ($reader.Read()) { } } finally { $reader.Dispose() }
}
Import-Module $ModulePath -RequiredVersion 1.24.0 -Force -ErrorAction Stop
$findings = @($files | ForEach-Object { Invoke-ScriptAnalyzer -Path $_.FullName -Settings "$root/PSScriptAnalyzerSettings.psd1" })
if ($findings.Count -gt 0) { $findings | Format-Table -AutoSize; $failed = $true }
if ($failed) { throw 'PowerShell validation failed.' }
Write-Output "PASS: $($files.Count) PowerShell files parsed, XML well formed, analyzer has no warning/error findings."
