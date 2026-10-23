# Directory operations and least privilege

Status: **Requires Windows Lab Validation** for all AD operations.

## Object model

`OU=Lab` contains `Users`, `Computers` and `Groups`. An OU is a directory container
used for delegation and GPO linking; it is not an access-control principal.
A security group is a principal used in resource ACLs and GPO security filtering.
Putting a user into a group does not move the user to an OU, and GPOs are not
linked directly to groups. Distribution groups are for messaging, not resource ACLs.

The scripts create global security groups `GG_Operations` and `GG_Finance`.
For a file server extension, use AGDLP: accounts → global role groups → domain-local
resource groups → permissions. Example: `GG_Finance` → `DL_FinanceShare_Read` →
read on the share and NTFS folder. Both share and NTFS access must allow the action;
group membership output alone does not establish effective access.

## Operating examples

```powershell
$dc = 'DC01.corp.example.test'
./scripts/onboarding/New-LabEmployee.ps1 -Server $dc -Identity alex.river -GivenName Alex -Surname River -Department Operations -WhatIf
./scripts/active-directory/Invoke-LabDirectory.ps1 -Server $dc -Action AddMember -Identity alex.river -Group GG_Operations -WhatIf
./scripts/active-directory/Invoke-LabDirectory.ps1 -Server $dc -Action Inspect -Identity alex.river
./scripts/active-directory/Invoke-LabDirectory.ps1 -Server $dc -Action ResetPassword -Identity alex.river -WhatIf
# Applying a reset requires -InitialPassword (Read-Host -AsSecureString).
./scripts/active-directory/Invoke-LabDirectory.ps1 -Server $dc -Action Unlock -Identity alex.river -WhatIf
./scripts/offboarding/Disable-LabEmployee.ps1 -Server $dc -Identity alex.river -WhatIf
```

Verify identity through the approved process before reset/unlock. Investigate
repeated lockouts instead of repeatedly unlocking. Check scheduled tasks, saved
credentials and mapped drives for old credentials. Never ask users for passwords.

## Delegation model

| Role | Intended rights | Explicit exclusions |
| --- | --- | --- |
| Tier 1 | Read users; reset passwords and unlock lab users | Group changes, GPO edit, privileged identities |
| Tier 2 provisioning | Create/disable lab users; manage approved role membership | Domain-root delegation, privileged groups |
| Endpoint join operator | Create approved computer objects in Lab Computers | Arbitrary domain joins, domain admin |
| GPO operator | Edit designated lab GPO and link at Lab Computers | Domain password policy, unrelated GPOs |

Configure delegation in ADUC/GPMC and test each account's denied as well as allowed
actions. The scripts' OU guards reduce mistakes; directory ACLs remain the security
boundary. Use an explicit domain controller to avoid default-domain mistakes.

Offboarding disables the account before removing managed memberships. It deliberately
does not remove Domain Users, move objects, delete data or pretend to terminate
existing sessions. Existing Kerberos/service sessions and cloud refresh tokens may
remain valid; use the manual offboarding checklist for complete access revocation.

## Acceptance tests

1. Initialize once; rerun and confirm existing OUs/groups are reused.
2. Preview CSV import: no users should appear; only the local activity log changes.
3. Apply the small batch; verify department, group, UPN and forced password change.
4. Try an account outside Lab Users and a CSV containing duplicate or invalid rows;
   confirm rejection before the batch creates any users.
5. Reset/unlock one fictional account and verify the expected state independently.
6. Disable it, verify role removal, then complete session/resource revocation manually.
7. Test share access as the user, including an expected access-denied case.
