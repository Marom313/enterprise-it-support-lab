# Default gateway issue

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

Local subnet services work but routed destinations fail.

## Possible causes

Missing/incorrect gateway; route conflict; failed upstream interface.

## Diagnostic steps

1. Run `Get-NetIPConfiguration` and `ipconfig /all`; compare subnet and gateway.
2. Use `route print` and `tracert -d 192.0.2.10` only if an authorized test destination exists.
3. Test the actual lab gateway with `Test-NetConnection`; check local versus routed reachability.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Correct approved DHCP option 003 or adapter configuration with console access. On a fully isolated lab network, absence of a gateway may be intentional.

Validation: Expected routes and service reachability across the intended segment boundary.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Router/firewall change, overlapping routes, network-wide impact or remote-only access risk.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P2, based on the simulated impact/urgency assessment.
- Initial report: Local subnet services work but routed destinations fail.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Correct approved DHCP option 003 or adapter configuration with console access. On a fully isolated lab network, absence of a gateway may be intentional.
- Closure notes: Expected routes and service reachability across the intended segment boundary. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
