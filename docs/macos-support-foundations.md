# macOS support foundations

**Learning Module — Not Hands-On Experience.** Marom has not performed practical
macOS administration. This reading module does not demonstrate use of macOS,
Jamf, Kandji or any Apple device-management platform. Commands below are study
examples, not execution evidence.

## Concepts to learn

- Filesystem: `/Users` stores home folders; `/Applications` stores applications;
  `/Library` and `~/Library` hold system-wide and per-user support data. APFS and
  protected system volumes differ from a typical Windows drive layout.
- Users: distinguish standard and administrator accounts; avoid routine admin use.
- Permissions: ownership, POSIX read/write/execute and ACLs can all affect access.
  Never repair an issue by recursively granting world-writable permissions.
- Network settings: identify the active interface, DHCP address, DNS, routes,
  VPN/proxy settings and current Wi-Fi network. Menu paths vary by OS version.
- Activity Monitor: examine CPU, memory pressure, disk and network activity;
  force quitting may lose unsaved data and needs user consent.
- Keychain: stores credentials and certificates. Do not dump stored secrets,
  reset a user's keychain casually or include its content in support artifacts.
- Terminal: inspect before changing state; `sudo` is an authorization boundary.

## Read-only command study

```bash
sw_vers
uname -a
id
ls -le "$HOME"
df -h
ps aux
networksetup -listallhardwareports
scutil --dns
route -n get default
```

Some commands expose user names/process arguments and must be sanitized. Do not
assume Wi-Fi uses `en0`; discover interfaces first. Commands are not a substitute
for macOS-specific privacy controls or an organization's support policy.

## Planned support exercises

1. Network failure: compare active interface, lease, resolver and route, then test
   the application. Escalate MDM/profile changes to the authorized owner.
2. Application unresponsive: preserve user work, inspect Activity Monitor and
   collect minimum diagnostic evidence before an approved force quit.
3. Permission denied: inspect ownership/ACL and affected path; request a scoped
   correction rather than `chmod -R 777`.
4. Repeated credential prompts: distinguish account authentication, certificate
   trust and keychain issues. Do not request or extract the user's password.

To claim practical experience later, perform these exercises on an authorized Mac,
record OS version, outcomes and sanitized screenshots, then update the experience
statement with exactly what was done. Until then this remains a learning module.
