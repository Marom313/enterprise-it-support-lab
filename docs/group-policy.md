# Group Policy lab

Status: **Requires Windows Lab Validation**. Only the screen-lock example is automated;
the remaining configurations are guided exercises in GPMC.

## Policy design

| Example | Scope and setting | Validation and recovery |
| --- | --- | --- |
| Screen lock | Computer Configuration → Windows Settings → Security Settings → Local Policies → Security Options → Interactive logon: Machine inactivity limit; 900 seconds | Measure idle lock on WS01; record prior value before changing |
| Password policy | Domain-root account policy for domain users; lab proposal: minimum 14 characters, complexity enabled, history 24 | Inspect effective domain policy and test with a fictional user; review before any apply |
| Account lockout | Domain account policy; lab proposal: 10 attempts, 15-minute duration and reset window | Prevent accidental denial of service; console/admin recovery available |
| Drive mapping | User Configuration → Preferences → Windows Settings → Drive Maps; Update `S:` to `\\FS01\Operations`; target GG_Operations | Test share and NTFS permissions first, then sign in as target user |
| Desktop configuration | User Configuration → Administrative Templates → Desktop → Desktop → Desktop Wallpaper using a reachable lab UNC | Confirm path access as user; revert policy and test refresh |
| Selected settings restriction | User Configuration → Administrative Templates → Control Panel → Prohibit access to Control Panel and PC settings | Link to Lab Users only; test standard user and remove restriction after exercise |

These are training values, not an organization-wide security baseline. Domain password
and lockout policies do not become per-department account policies by linking them
to user OUs. Use reviewed domain-root policy or fine-grained password policies
targeted to users/global security groups when appropriate. Do not modify the Default
Domain Policy through an unreviewed automation script.

## Apply and inspect

```powershell
./scripts/group-policy/Set-LabGpo.ps1 -WhatIf
gpupdate /target:computer /force
gpupdate /target:user /force
gpresult /r
gpresult /scope computer /r
# In an elevated session, after creating the outputs directory:
gpresult /h ./outputs/gpresult.html
```

Computer settings follow the computer object; user settings follow the user object.
Loopback processing changes user-policy behavior based on the computer and must be
an explicit design choice. Use GPMC Group Policy Results to examine precedence,
inheritance, filtering, WMI filters and disabled configuration halves.

## Security filtering

A linked GPO still needs Read and Apply Group Policy for its target principal.
When narrowing user GPO filtering to a group, preserve computer read access using
Authenticated Users or Domain Computers with Read only as appropriate. Do not
remove all computer read access. Preference item-level targeting controls an item;
it does not grant share access. Never store passwords in Group Policy Preferences.

## Troubleshooting exercise: policy missing on WS01

Symptoms: the fictional user remains unlocked after 15 minutes, or the drive is absent.

1. Record computer/user names, ticket time and intended setting. Check the relevant
   object is in the linked OU, and that the link and configuration half are enabled.
2. Check DNS points to DC01, clock alignment and domain secure channel health.
3. Run `gpresult /r` in the affected user's session and elevated computer scope.
4. Inspect denied GPOs, Read/Apply permissions, WMI filters and group token freshness.
5. Inspect inheritance, higher-priority policies, enforced links and block inheritance.
6. Check Event Viewer → Microsoft → Windows → GroupPolicy → Operational.
7. After a scoped correction, run `gpupdate /force`; sign out/in for group token
   changes and reboot only when required. Test actual behavior and save sanitized results.

Escalate replication errors, inaccessible SYSVOL, unexplained security filtering or
any need to change domain-root policy. Ticket closure must name the denied reason,
the approved change and the independent behavior test. Restore the previous value
if the change causes unexpected locking or loss of required settings access.

References: [Microsoft Group Policy preferences](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-preferences)
and [computer Read permissions for user GPOs](https://learn.microsoft.com/en-us/troubleshoot/windows-server/group-policy/cannot-apply-user-gpo-when-computer-objects-dont-have-read-permissions).
