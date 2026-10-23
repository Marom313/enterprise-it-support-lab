# Evidence register

No infrastructure screenshots have been captured for this repository. Do not use
sample JSON, tickets, architecture diagrams or mocked output as deployment proof.
Repository automation results are recorded separately in [validation](../docs/validation.md).

## Capture after running the Windows lab

| Suggested file | Required content | Claim it can support |
| --- | --- | --- |
| `ad-structure.png` | Lab OUs, fictional user and security group | Objects exist in the tested lab |
| `least-privilege.png` | Allowed operation and denied unrelated operation | Specific tested delegated rights |
| `gpo-result.png` | gpresult applied GPO and client behavior evidence | Policy scope and observed application |
| `network-diagnosis.png` | Actual before/after DNS or DHCP checks | Executed troubleshooting case |
| `deployment-validation.png` | Actual validator results with image/version context | Reported post-deployment checks |
| `asset-handover.png` | Fictional asset and completed checklist | Documented lab lifecycle exercise |

Before adding evidence, record date, OS versions, steps, expected/actual outcomes
and limitations in a companion Markdown note. Crop account/email details, secrets,
license/recovery keys, real network addresses and unrelated windows. Use fictional
lab identities. Inspect final pixels, not only source text. Keep raw captures in
ignored `evidence/private/`. Never commit unreviewed output files.
