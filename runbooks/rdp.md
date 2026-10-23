# RDP connection failure

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

Authorized support cannot establish a remote desktop session.

## Possible causes

Host asleep/offline; edition lacks RDP host; listener/firewall issue; missing authorized membership; NLA/time issue.

## Diagnostic steps

1. Confirm consent, target identity, allowed edition and network path.
2. Run `Resolve-DnsName WS01.corp.example.test` and `Test-NetConnection WS01.corp.example.test -Port 3389`.
3. Use console access to inspect Remote Desktop settings, TermService and approved access group; inspect relevant events.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Repair the approved listener, entitlement or scoped rule. Preserve NLA and do not expose RDP to the public internet.

Validation: Authorized RDP logon and expected session access; a TCP pass alone is not acceptance.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Account/NLA/certificate errors, exposed listener, policy change or no console recovery.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P3, based on the simulated impact/urgency assessment.
- Initial report: Authorized support cannot establish a remote desktop session.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Repair the approved listener, entitlement or scoped rule. Preserve NLA and do not expose RDP to the public internet.
- Closure notes: Authorized RDP logon and expected session access; a TCP pass alone is not acceptance. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
