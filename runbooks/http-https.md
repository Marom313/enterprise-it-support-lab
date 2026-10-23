# HTTP or HTTPS access failure

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

Browser reports timeout, certificate warning or HTTP error.

## Possible causes

DNS/path failure; proxy; no listener; expired/untrusted certificate; application/auth issue.

## Diagnostic steps

1. Resolve the host and run `Test-NetConnection portal.corp.example.test -Port 443`.
2. Use `curl.exe -I https://portal.corp.example.test` for an authorized lab service; record status without cookies/tokens.
3. Compare affected browser/proxy settings, clock and certificate chain/name. A 401/403 is not a TCP failure.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Correct approved proxy/DNS settings, request certificate renewal or route the application error to its owner. Never bypass TLS verification to close a ticket.

Validation: Trusted TLS and expected authorized application response; no sensitive headers in evidence.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Certificate compromise, multiple affected users, server error or required proxy/firewall change.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P3, based on the simulated impact/urgency assessment.
- Initial report: Browser reports timeout, certificate warning or HTTP error.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Correct approved proxy/DNS settings, request certificate renewal or route the application error to its owner. Never bypass TLS verification to close a ticket.
- Closure notes: Trusted TLS and expected authorized application response; no sensitive headers in evidence. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
