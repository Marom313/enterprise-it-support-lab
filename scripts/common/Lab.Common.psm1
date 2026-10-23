Set-StrictMode -Version Latest

function Write-LabLog {
    <#
    .SYNOPSIS
    Writes a timestamped operation record without object payloads or credentials.
    .EXAMPLE
    Write-LabLog -Message 'Inventory completed' -Path './outputs/activity.log'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Message,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Path
    )
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop | Out-Null
    }
    Add-Content -LiteralPath $Path -Value ('{0:o} {1}' -f (Get-Date), $Message) -ErrorAction Stop
}

function Export-LabJson {
    <#
    .SYNOPSIS
    Writes private local JSON output. Existing files require explicit overwrite.
    .EXAMPLE
    Export-LabJson -Data @{ Status = 'Pass' } -Path './outputs/check.json'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][object]$Data,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Path,
        [switch]$Overwrite
    )
    if ((Test-Path -LiteralPath $Path) -and -not $Overwrite) { throw 'Output exists; choose another path or use -Overwrite.' }
    if ($PSCmdlet.ShouldProcess($Path, 'Write local JSON report')) {
        $parent = Split-Path -Parent $Path
        if ($parent) { New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop | Out-Null }
        $Data | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $Path -Encoding UTF8 -ErrorAction Stop
    }
}

function Assert-LabWindows {
    <#
    .SYNOPSIS
    Rejects Windows-only operations on other operating systems.
    .EXAMPLE
    Assert-LabWindows
    #>
    [CmdletBinding()]
    param()
    if ($env:OS -ne 'Windows_NT') { throw 'Requires a Windows lab host.' }
}

Export-ModuleMember -Function Write-LabLog, Export-LabJson, Assert-LabWindows
