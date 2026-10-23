# Security and privacy

All committed users, devices, serial numbers and network examples are fictional.
Author name and requested public profile links are intentionally public attribution.
No employer data, real tickets, credentials or actual endpoint reports belong here.

## Least privilege and secure credentials

Delegate only the required AD OU actions. Keep provisioning, endpoint join and GPO
editing roles separate. Validate both allowed and denied operations. Scripts'
validation is defense against mistakes, not a substitute for directory ACLs.
Use `Read-Host -AsSecureString` and `Get-Credential` interactively; never use a
literal password, command-line secret, environment dump or transcript containing
credentials. SecureString is an interface for safer handling, not permission to
store secrets or a guarantee of protection against a compromised administrator.

Mutating scripts use ShouldProcess and explicit scope. WhatIf can still read state
and write minimal activity logs; it requires connectivity/RSAT for AD inspection.
Read-only collectors write reports but do not repair services or change settings.
Do not use production as the test environment or weaken execution policy globally.

## Data sanitization

Generated JSON can contain user/device names, IPs, paths and software versions.
Ignored files are not automatically encrypted, access-controlled or sanitized.
Use a private local folder with appropriate ACLs and retention; `outputs/` is an
ignore convention, not a security boundary. Event collection omits messages but
metadata can still be sensitive. Review content manually before sharing.

For publishable evidence, copy only needed fields, replace identifiers with fictional
values, remove tokens/cookies/headers/keys, inspect the rendered screenshot and label
synthetic examples accurately. Review Git's staged diff before every public commit.
Never publish Windows images, license keys, recovery keys or proprietary installers.

## Secret checks and response

`npm run validate` checks repository text for credential-like assignments, common
token formats and private key markers; CI also runs Gitleaks across Git history.
These checks have false positives and false negatives and do not prove the absence
of every secret. Review diffs and generated evidence independently. If a secret is
exposed, revoke/rotate it first, then follow the provider's history-cleanup procedure;
deleting the current file alone does not remove it from history.
