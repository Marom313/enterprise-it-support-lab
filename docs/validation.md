# Validation record

This file records repository checks, not infrastructure execution. The definitive
current results are the actual local command output and GitHub Actions run, when
available. Do not infer a successful domain deployment from a successful CI run.

## Automated scope

| Check | Tool | Scope |
| --- | --- | --- |
| PowerShell syntax | PowerShell AST parser | Scripts, module and test entry points |
| PowerShell lint | PSScriptAnalyzer 1.24.0 | Default warning/error rules with one documented nested-scriptblock suppression |
| Markdown | markdownlint | Authored Markdown, excluding private/generated files |
| JSON/YAML | JSON.parse and yaml | Repository JSON and GitHub workflow |
| XML | .NET XmlReader, DTD disabled | XML well-formedness; not Windows SIM schema validation |
| File links | Local path resolution | Relative Markdown file targets; external URLs/anchors are not checked |
| Secret patterns | Local scanner | Current public text, synthetic positive/negative scanner checks |
| Secret history | Gitleaks in CI | Git history; not claimed locally until actually run |
| Sample integrity | Node assertions | Fictional report label/status, CSV fields/unique IDs, ticket count |
| Regression behavior | Windows PowerShell | Output WhatIf, overwrite rejection, report rendering and invalid status rejection |

Generated `outputs/` is excluded from publication and repository content checks.
This is not a general DLP audit. Inspect staged changes and all screenshots manually.
The sample report explicitly contains Pass/Fail/Review to exercise reporting; those
states are fictional inputs, not recorded machine checks.

## Requires Windows Lab Validation

- AD module behavior, scoped OU creation and all account/group operations.
- Delegated permission allow/deny tests and effective share/NTFS access.
- Domain join, reboot and secure channel verification.
- GPO creation, linking, filtering and observable client behavior.
- CIM/registry/software inventory completeness on the intended client editions.
- Real DNS/DHCP/Wi-Fi/RDP/HTTP fault injection and recovery.
- Windows activation/provider access, application launch and full update compliance.
- Windows SIM answer-file validation, Sysprep, image capture and deployment.
- User acceptance, timing/SLA evidence and sanitized screenshots.

## Reproduce

```powershell
npm ci --ignore-scripts
npm test
./tests/Test-PowerShell.ps1
./tests/Test-Behavior.ps1
```

PSScriptAnalyzer must be installed separately; see [setup](setup-guide.md).
## Recorded local results — 23 October 2026

Windows PowerShell 5.1 and Node.js 24.19.0 were available on the authoring host.
No AD/GroupPolicy execution or workstation inventory of that host was performed.

- `npm test`: passed local file links, JSON/YAML, secret patterns, sample integrity
  and Markdown lint (43 Markdown files at the time of recording).
- `Test-PowerShell.ps1`: passed AST parsing of 15 script/module/test files, XML
  well-formedness and PSScriptAnalyzer 1.24.0 with no warning/error findings.
- `Test-Behavior.ps1`: passed JSON WhatIf, default overwrite rejection, report
  WhatIf, preservation of a Fail finding and malformed-status rejection.
- `npm audit --audit-level=low`: zero known vulnerabilities reported by the live
  registry after dependency updates. A pinned KaTeX 0.18.2 override patches the
  Markdown parser's transitive math-rendering dependency; no math content is needed.
- `git diff --check`: passed whitespace checks before publication.

The analyzer has a targeted suppression for `PSReviewUnusedParameter` on the
deployment validator: those parameters are consumed in synchronously invoked probe
scriptblocks, which the rule does not follow. No blanket unused-parameter rule
exclusion is applied. Formatting/line-length choices are not security test results.

GitHub Actions and Gitleaks results must be checked in the actual run; the presence
of their workflow definitions does not by itself establish success.
