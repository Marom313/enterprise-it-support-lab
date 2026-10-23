# Build the Windows lab

Status: **Requires Windows Lab Validation**. No domain controller, domain join,
image capture or image deployment is claimed by this repository.

## Prerequisites

- A virtualization-capable computer; approximately 16 GB host RAM and 100 GB free
  storage are a practical starting point for two VMs.
- Properly licensed or evaluation Windows Server and supported domain-capable
  Windows 11 editions. Windows Home cannot join AD DS.
- Windows PowerShell 5.1 for AD/GroupPolicy scripts; RSAT AD DS and GPMC tools.
  PowerShell 7 requires testing of module compatibility before using these tools.
- Git, Node.js 22 or later for repository validation, and PSScriptAnalyzer 1.24.0.
- Snapshots, an isolated network, approved lab credentials and console access.

## Provision infrastructure manually

1. Create an isolated VM network and snapshots of clean VMs.
2. Set DC01 to a static lab address. Install AD DS and DNS using Server Manager.
3. Promote DC01 to a new forest `corp.example.test`; enter a unique DSRM secret
   interactively. Never store it in this repository.
4. Point WS01 DNS to DC01, not a public resolver. Verify time and connectivity.
5. If exercising DHCP, create an isolated scope excluding DC01. Configure DNS
   option 006 and domain option 015. Add option 003 only for a real lab gateway.
6. Install RSAT on the management workstation and open Windows PowerShell.
7. Use the commands below to preview the managed structure, then review and apply.

```powershell
# From the repository root; read the scripts before applying changes.
Get-Help ./scripts/active-directory/Invoke-LabDirectory.ps1 -Full
./scripts/active-directory/Invoke-LabDirectory.ps1 -Action Initialize -Server DC01.corp.example.test -WhatIf
# Remove -WhatIf only in the isolated lab. Confirm each intended change.
./scripts/active-directory/Invoke-LabDirectory.ps1 -Action Initialize -Server DC01.corp.example.test
./scripts/active-directory/Import-LabUsers.ps1 -Server DC01.corp.example.test -CsvPath ./sample-data/users.csv -WhatIf
```

For actual bulk creation, supply `-InitialPassword (Read-Host -AsSecureString)`.
The small fictional batch can share a temporary lab password, but real onboarding
requires unique per-user secrets through an approved delivery channel. Each created
user must change the password at first logon. Batch writes are not transactional:
if one operation fails, stop and inspect existing objects before retrying.

## Join, apply and verify

```powershell
./scripts/active-directory/Join-LabDomain.ps1 -WhatIf
./scripts/active-directory/Join-LabDomain.ps1 -Credential (Get-Credential)
# Reboot the workstation manually after confirming the join succeeded.
./scripts/group-policy/Set-LabGpo.ps1 -WhatIf
./scripts/group-policy/Set-LabGpo.ps1
gpupdate /force
New-Item -ItemType Directory -Path ./outputs -Force
gpresult /h ./outputs/gpresult.html
./scripts/imaging/Test-LabDeployment.ps1 -ExpectedName WS01
./scripts/support/New-SupportReport.ps1 -InputPath ./outputs/deployment.json
```

Run GPO creation on an authorized management host; run `gpupdate`, `gpresult`
and deployment validation on WS01. Inspect every Fail, Review and Unknown result.
The validator does not silently install applications, reboot or repair services.

## Repository checks

```powershell
npm ci --ignore-scripts
npm test
Install-Module PSScriptAnalyzer -RequiredVersion 1.24.0 -Scope CurrentUser
./tests/Test-PowerShell.ps1
./tests/Test-Behavior.ps1
```

Do not change execution policy globally. Follow the host's script-signing policy;
inspect downloaded files and unblock only individually reviewed lab files if needed.
There is no Docker/ITSM server dependency: tickets are versioned Markdown examples.

## Recovery and cleanup

Keep the original VM snapshot and a console session before changing networking.
Remove GPO links or restore recorded registry policy values through an approved
change. Removing a GPO link alone may leave security values behind. Disable sample
accounts before deleting them. Do not automate deletion of protected OUs. For a
disposable lab, deleting the isolated VMs after exporting sanitized evidence is
simpler than reversing every directory change. Never restore a DC snapshot as a
substitute for a production AD recovery procedure.
