# Employee offboarding checklist

Fictional lab workflow; access removal must follow approved authority and timing.

- [ ] Verify departure instruction, effective time and authorizing owner.
- [ ] Agree data retention, legal hold and authorized ownership transfer.
- [ ] Inventory AD, applications, cloud access, VPN, shared secrets and devices.
- [ ] Preview `Disable-LabEmployee.ps1 -WhatIf`; confirm intended account and OU.
- [ ] Disable AD account first; remove the script-managed role groups.
- [ ] Review other memberships and privileged access separately.
- [ ] Revoke active application/cloud sessions, refresh tokens and remote sessions.
- [ ] Rotate shared secrets if the departing user had access; follow change controls.
- [ ] Transfer approved data without exposing personal or retained legal information.
- [ ] Recover laptop/accessories; record custody and lock/wipe under approved policy.
- [ ] Verify access denial and downstream completion with responsible owners.
- [ ] Set retention review/deletion date; do not delete the account immediately.
- [ ] Record confirmation, asset state and unresolved tasks before closure.

Disabling AD does not immediately invalidate every existing Kerberos ticket,
application session or offline sign-in. The script is one step in this checklist.
