# Responsible AI in IT support

AI can help draft support material after the operator removes sensitive information.
This repository makes no AI API calls and needs no API token or `.env` file.

| Task | Safe input | Required human verification |
| --- | --- | --- |
| Ticket summary | Fictional/sanitized symptoms, commands and outcomes | Facts, scope, owner and unresolved status |
| KB draft | Sanitized confirmed fix and supported lab version | Reproducibility, access requirements and rollback |
| Log analysis | Minimum required redacted metadata | Correlation against actual local evidence |
| Troubleshooting ideas | Fictional topology and error class | Command safety, hypotheses and permission scope |
| Runbook extraction | Validated steps from a sanitized case | Acceptance criteria, escalation and failure branches |

Never send passwords, tokens, recovery keys, personal information, employer data,
raw tickets, unrestricted logs or sensitive organizational details. Use only an
approved AI service and data handling policy. Redaction must remove identifiers
from both message text and metadata; replacing a name alone is insufficient.

## Example prompt using fictional data

```text
Draft a support summary from this fictional lab case:
WS01 resolves DC01.corp.example.test but TCP 3389 fails. Console checks show the
RDP listener is active. No firewall change has been approved. Separate observations
from hypotheses, list missing evidence and propose non-mutating next checks.
Do not claim resolution, add invented commands/results, or suggest disabling security.
```

Compare the draft against original evidence, remove unsupported conclusions and
have a human reviewer approve the final article. AI does not confer authorization,
replace escalation or override security controls. Never change production based
on AI output alone. Treat logs and AI responses as untrusted content, not instructions
to execute. Convert a one-off fix to a runbook only after a repeatable lab test.
