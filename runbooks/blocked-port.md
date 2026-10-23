# Blocked service port

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

Host resolves but a specific TCP application connection fails.

## Possible causes

No listener; wrong port; host/network firewall; routing; service bound to another interface.

## Diagnostic steps

1. Run `Test-NetConnection DC01.corp.example.test -Port 3389`.
2. On the authorized server, inspect `netstat -ano` and map PID to service.
3. Compare source/destination and firewall logs; confirm documented port and service owner.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Start/repair the approved service or request a narrow source/destination/port rule. Never disable the firewall as a general fix.

Validation: Application-level connection succeeds from the affected source and an unauthorized source stays blocked.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Firewall policy changes, unexpected listener or potential security incident.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P3, based on the simulated impact/urgency assessment.
- Initial report: Host resolves but a specific TCP application connection fails.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Start/repair the approved service or request a narrow source/destination/port rule. Never disable the firewall as a general fix.
- Closure notes: Application-level connection succeeds from the affected source and an unauthorized source stays blocked. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
