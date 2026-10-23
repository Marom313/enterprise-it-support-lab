# IP works, host name fails

Fictional lab exercise ? **Requires Windows Lab Validation**.

## Symptoms

An internal IP responds but the equivalent DNS name does not.

## Possible causes

Wrong resolver; suffix/search issue; stale cache; missing A/AAAA record.

## Diagnostic steps

1. Run `ping 192.168.56.10`, then `ping DC01.corp.example.test`; record distinct outcomes.
2. Use `nslookup` and `Resolve-DnsName` against the configured and intended internal resolver.
3. Compare short name with FQDN; inspect hosts file read-only and DNS cache.

Record time, scope, recent changes and a known-good comparison before changing anything.
An ICMP timeout can be filtering; it does not independently establish host failure.

## Resolution

Fix the resolver/suffix or approved record; do not use permanent hosts entries as a substitute for DNS repair.

Validation: FQDN and expected short name resolve and the target service works; ping alone is insufficient.
If the change fails, restore the recorded prior configuration and preserve console access.

## Escalation criteria

Unexpected external answer, inconsistent records or multiple affected subnets.
Escalate suspected compromise to security immediately; stop unapproved changes.

## Ticket documentation example

Fictional example, not a completed support engagement:

- Priority: P3, based on the simulated impact/urgency assessment.
- Initial report: An internal IP responds but the equivalent DNS name does not.
- Troubleshooting performed: recorded configuration, compared working client and tested the specific failing layer.
- Resolution: Fix the resolver/suffix or approved record; do not use permanent hosts entries as a substitute for DNS repair.
- Closure notes: FQDN and expected short name resolve and the target service works; ping alone is insufficient. User confirmation required before closing.
- Evidence: add sanitized timestamps and actual commands/results after the exercise; do not invent measurements.
