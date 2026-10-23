# DNS resolution failure

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

Internal host names return NXDOMAIN, time out or resolve incorrectly.

## Possible causes

Public DNS configured on AD client; missing/stale record; DNS service unreachable.

## Diagnostic steps

1. Run `Get-NetIPConfiguration` and inspect DNS servers.
2. Run `Resolve-DnsName DC01.corp.example.test` and `nslookup DC01.corp.example.test 192.168.56.10`.
3. Compare authoritative/internal response, suffix and reachable DNS server; record error type.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Correct client DHCP/DNS settings or request an authorized record correction. Flush the client cache only after the source problem is fixed.

Validation: Correct answer from intended resolver and successful application connection by name.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

DNS zone/replication issue, widespread timeouts or record changes without ownership.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P3, based on the simulated impact/urgency assessment.
- Initial report: Internal host names return NXDOMAIN, time out or resolve incorrectly.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Correct client DHCP/DNS settings or request an authorized record correction. Flush the client cache only after the source problem is fixed.
- Closure notes: Correct answer from intended resolver and successful application connection by name. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
