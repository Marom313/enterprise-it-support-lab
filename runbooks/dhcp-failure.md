# DHCP lease failure

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

A workstation cannot renew its lease or has stale network options.

## Possible causes

Stopped DHCP service; exhausted pool; failed relay; incorrect DHCP options.

## Diagnostic steps

1. Compare `ipconfig /all` against the approved scope and a working host.
2. Check lease expiry, scope utilization and exclusions.
3. Ask the network owner to verify relay/VLAN and DHCP event evidence.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Restore the approved scope/service or correct the relay through an approved change. Renew only the affected client after recording its old state.

Validation: Lease obtained with correct option 006/015 and real gateway if configured.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Scope-wide issue, authorization failure, relay changes or recurring exhaustion.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P2, based on the simulated impact/urgency assessment.
- Initial report: A workstation cannot renew its lease or has stale network options.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Restore the approved scope/service or correct the relay through an approved change. Renew only the affected client after recording its old state.
- Closure notes: Lease obtained with correct option 006/015 and real gateway if configured. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
