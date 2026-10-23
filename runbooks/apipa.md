# APIPA address

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

WS01 receives 169.254.x.x and cannot reach domain services.

## Possible causes

No DHCP offer; disconnected virtual switch; exhausted scope; wrong VLAN.

## Diagnostic steps

1. Run `ipconfig /all`; record adapter, DHCP enabled state, lease and DNS.
2. Check link/virtual switch and compare another client in the same segment.
3. Check DHCP scope availability, service status and server logs with the owner.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Correct the isolated switch/scope issue. With local console access and approval, renew the affected adapter lease; do not release a remote session's only interface.

Validation: Valid lease, intended DNS and gateway; reach DC and repeat application test.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Multiple clients affected, suspected rogue DHCP, no scope rights or no offer despite healthy link.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P2, based on the simulated impact/urgency assessment.
- Initial report: WS01 receives 169.254.x.x and cannot reach domain services.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Correct the isolated switch/scope issue. With local console access and approval, renew the affected adapter lease; do not release a remote session's only interface.
- Closure notes: Valid lease, intended DNS and gateway; reach DC and repeat application test. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
