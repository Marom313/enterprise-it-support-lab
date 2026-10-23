# Employee onboarding checklist

Fictional lab workflow. Link an approved request before applying changes.

- [ ] Verify requester authority, identity, start date and department.
- [ ] Agree access scope with the manager; separate standard/admin accounts.
- [ ] Check for existing identities and approved naming convention.
- [ ] Preview `New-LabEmployee.ps1 -WhatIf` with an explicit domain controller.
- [ ] Create the account with a secure temporary password and first-logon change.
- [ ] Confirm only approved role groups; test allowed and denied resource access.
- [ ] Complete application/license/MFA enrollment manually where applicable.
- [ ] Allocate an available asset; record asset ID, accessories and custody.
- [ ] Validate image, drivers, updates, applications, encryption process and GPO.
- [ ] Verify sign-in and required user workflow without obtaining the user's password.
- [ ] Provide support contact and basic security guidance.
- [ ] Record user acceptance and close the request; keep secrets outside tickets/Git.

The script creates the AD identity only. It does not provision SaaS accounts,
configure MFA, escrow recovery keys or deliver physical hardware.
