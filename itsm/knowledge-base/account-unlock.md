# Account unlock after identity verification

Status: Draft learning procedure — Requires Windows Lab Validation.
Audience: delegated support operator. Scope: fictional Lab Users OU only.

1. Verify requester identity and the approved ticket. Never ask for a password.
2. Inspect account state using the directory script's `Inspect` action.
3. Ask about recent password changes, mapped drives and old saved credentials.
4. Preview `Unlock` with `-WhatIf`; apply only to the approved account.
5. Ask the user to retry normal sign-in. Do not unlock repeatedly without diagnosis.
6. Record the result without passwords. Escalate recurrence or unusual source activity.

Unlock does not reset a password, revoke sessions or remove the cause. If the
request cannot be verified, stop the account change and escalate to the identity owner.
