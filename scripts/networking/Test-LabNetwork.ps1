<#
.SYNOPSIS
Runs bounded DNS, ICMP and TCP diagnostics against an explicit lab target.
.DESCRIPTION
Reads interface state and sends DNS queries, one ICMP test and one TCP probe.
Does not reset adapters, change DNS, renew DHCP, or scan port ranges.
Writes private JSON and an activity log. WhatIf skips collection and probes.
.EXAMPLE
./Test-LabNetwork.ps1 -Target DC01.corp.example.test -Port 3389
.EXAMPLE
./Test-LabNetwork.ps1 -Target 192.168.56.10 -Port 443 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9.-]{0,252}$')][string]$Target,
    [ValidateRange(1,65535)][int]$Port = 443,
    [ValidateNotNullOrEmpty()][string]$OutputPath = './outputs/network.json',
    [ValidateNotNullOrEmpty()][string]$LogPath = './outputs/network.log',
    [switch]$Overwrite
)
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
try {
    Assert-LabWindows
    if ($PSCmdlet.ShouldProcess($Target, "Run DNS/ICMP/TCP $Port diagnostics")) {
        $dnsError = $null
        $dns = try { @(Resolve-DnsName -Name $Target -ErrorAction Stop | Select-Object Name,Type,IPAddress,NameHost) } catch { $dnsError = 'Resolution failed; inspect resolver and target'; @() }
        $result = [ordered]@{
            CollectedAt = (Get-Date).ToUniversalTime().ToString('o')
            Target = $Target
            Port = $Port
            Interfaces = @(Get-NetIPConfiguration | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer)
            DNS = $dns
            DNSError = $dnsError
            ICMP = [bool](Test-Connection -ComputerName $Target -Count 1 -Quiet -ErrorAction SilentlyContinue)
            TCP = [bool](Test-NetConnection -ComputerName $Target -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue)
        }
        Export-LabJson -Data $result -Path $OutputPath -Overwrite:$Overwrite
    }
    Write-LabLog -Message "Network diagnostics completed; WhatIf=$WhatIfPreference" -Path $LogPath
} catch {
    Write-LabLog -Message 'Network diagnostics failed; inspect locally' -Path $LogPath
    throw
}
