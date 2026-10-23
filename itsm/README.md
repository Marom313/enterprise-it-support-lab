# Service management model

This lightweight ITSM model uses versioned fictional records rather than a hosted
ticket system. It demonstrates process design; it does not claim ITIL certification,
live users, production operations or achieved SLAs.

| Record | Purpose | Example |
| --- | --- | --- |
| Incident | Restore an interrupted service | DNS failure prevents access |
| Service Request | Fulfil an approved standard request | New starter account |
| Problem | Investigate causes of one or more incidents | Recurring DHCP exhaustion |
| Change | Assess, approve and track a controlled modification | Pilot GPO rollout |
| Knowledge | Preserve reviewed, reusable support guidance | Verified account-unlock article |

## Priority and SLA targets

These targets are illustrative business-hour objectives, not contractual commitments.
Business hours: Sunday–Thursday, 09:00–18:00 Asia/Jerusalem, excluding agreed holidays.
P1 requires a separate on-call agreement for 24/7 coverage; this lab has none.

| Priority | Impact and urgency example | Initial response | Resolution/restoration target | Update cadence |
| --- | --- | --- | --- | --- |
| P1 Critical | Broad critical service outage, no workaround | 15 business minutes | 4 business hours | 30 business minutes |
| P2 High | Department blocked or time-critical onboarding/access risk | 30 business minutes | 8 business hours | 2 business hours |
| P3 Normal | One user impaired; limited workaround or standard request | 4 business hours | 3 business days | Each business day |
| P4 Low | Cosmetic issue, guidance or planned improvement | 1 business day | 5 business days | Every 2 business days |

Urgency alone does not define P1. Assess affected users/services, business impact,
workaround and deadline; document priority changes. Response means a meaningful
human acknowledgement and ownership, not an automatic receipt. For incidents,
restoration may use an agreed workaround; root-cause work can remain in a linked
problem. Request delivery dates are agreed separately when procurement is involved.

Track received, first response, assignment, each transition, resolved and closed
timestamps. Waiting states do not silently stop the clock: pause rules must be
explicitly agreed and visible to the requester. Escalate at 50% target consumption
if stalled and before breach; document owner and next update. No metrics are
claimed from these sample records.

## Escalation matrix

| Level | Responsibility | Trigger | Handoff evidence |
| --- | --- | --- | --- |
| Tier 1 | Triage, identity verification, documented safe diagnostics | No progress after runbook or delegated rights insufficient | Impact, scope, timestamps, results, attempted changes |
| Tier 2 | Directory, endpoint and complex client diagnosis | Server/network dependency or failed scoped correction | Known-good comparison, logs sanitized, rollback state |
| Infrastructure owner | AD/DNS/DHCP, routing, server and policy changes | Shared-service impact or privileged change | Service dependency, exact request, approved scope |
| Security owner | Suspected compromise or access/data exposure | Immediately on credible indicator | Preserve evidence privately; avoid further experimentation |
| Change approver | Risk, schedule, implementation and rollback review | Nonstandard configuration or broad impact | Test plan, blast radius, recovery and acceptance gates |

See [workflow](../docs/it-support-workflow.md), [sample tickets](sample-tickets/README.md),
[onboarding](onboarding-checklist.md), [offboarding](offboarding-checklist.md)
and [knowledge base](knowledge-base/README.md).
