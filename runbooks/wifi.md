# Wi-Fi connectivity

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

Client disconnects or connects without reaching internal services.

## Possible causes

Weak signal; incorrect SSID; expired auth; AP/VLAN issue; adapter driver problem.

## Diagnostic steps

1. Check radio state, airplane mode, signal and intended SSID without recording keys.
2. Run `netsh wlan show interfaces` and `ipconfig /all`; inspect authentication and lease state.
3. Compare wired connection or a known-good device; correlate disconnect times with AP evidence.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Reconnect to the approved SSID; update an approved driver or escalate AP/authentication issues. Forget/recreate a profile only after confirming a recovery path.

Validation: Stable connection, correct address/DNS and successful user workflow.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Multiple clients/APs, certificate/RADIUS issue or suspected unauthorized SSID.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P3, based on the simulated impact/urgency assessment.
- Initial report: Client disconnects or connects without reaching internal services.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Reconnect to the approved SSID; update an approved driver or escalate AP/authentication issues. Forget/recreate a profile only after confirming a recovery path.
- Closure notes: Stable connection, correct address/DNS and successful user workflow. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
