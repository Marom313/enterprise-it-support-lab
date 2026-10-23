# Windows imaging and deployment

Marom has prior hands-on experience preparing computers and installing images.
The procedures and validator here are portfolio artifacts; no image capture or
deployment is claimed without separately recorded lab evidence.

## Golden image lifecycle

A golden image is a versioned reference installation prepared for reuse. Keep it
minimal, patched and free of personal profiles, cached credentials, domain identity
and device-specific secrets. Document OS build, approved software versions, image
hash, creation date, licensing requirements and supported hardware models.

1. Use a disposable reference VM with licensed media and a clean snapshot.
2. Enter Audit Mode, apply approved updates, restart and remove pending operations.
3. Install only approved applications using documented, trusted installers. Verify
   signatures/hashes and license terms; do not bundle proprietary installers in Git.
4. Stage signed vendor drivers for each model. Avoid mixing unrelated driver packs;
   validate NIC and storage drivers in the boot environment as well as Windows.
5. Remove temporary files and secrets. Do not join the reference image to AD.
6. Validate [unattend.xml](../scripts/imaging/unattend.xml) against the exact image
   catalog in Windows System Image Manager. It only supplies locale settings;
   it does not create users, bypass OOBE, wipe disks or supply a product key.
7. In the disposable reference machine, review before running:

   ```powershell
   # Destructive preparation step: reference VM only; never a user's working machine.
   & "$env:WINDIR\System32\Sysprep\Sysprep.exe" /generalize /oobe /shutdown /unattend:C:\Lab\unattend.xml
   ```

8. After shutdown, capture offline with an approved imaging tool/WinPE workflow.
   Do not boot the reference image before capture. Store images outside Git.
9. Apply to an expendable test VM/device, complete OOBE and assign a unique name.
10. Install model-specific drivers and approved apps; inspect Device Manager.
11. Set AD DNS, verify time, join to the intended computer OU using delegated rights,
    reboot and apply GPO. Domain credentials must not be embedded in an answer file.
12. Run the validator, review non-Pass results, test actual applications and obtain
    user acceptance. Record evidence before declaring the image approved.

## Deployment checklist

- [ ] Change/ticket, image version, hash and target asset recorded.
- [ ] Backup and recovery plan verified; restore tested where data is at risk.
- [ ] Power, network isolation, storage and firmware requirements checked.
- [ ] Reference system generalized and captured offline.
- [ ] Correct storage/NIC drivers and unique name applied.
- [ ] Activation state verified without exposing keys.
- [ ] Domain/OU, GPO, DNS, time and service connectivity verified.
- [ ] Required apps launched successfully, not just detected in registry.
- [ ] Windows Update scan reviewed; pending reboot cleared appropriately.
- [ ] Device Manager, event errors, free disk and security controls reviewed.
- [ ] Asset register, ticket and sanitized evidence updated.

## Acceptance and recovery

```powershell
./scripts/imaging/Test-LabDeployment.ps1 -ExpectedName WS01 -WhatIf
./scripts/imaging/Test-LabDeployment.ps1 -ExpectedName WS01 -ExpectedDomain corp.example.test
./scripts/support/New-SupportReport.ps1 -InputPath ./outputs/deployment.json
```

Activation reports state only. Update evidence uses hotfix history and selected
pending-reboot markers; it cannot prove patch compliance or replace Windows Update.
Event checks examine at most the newest 1,000 records per channel, not the entire
time window when log volume is high. Permission failures are Unknown, never Pass.

Stop rollout on a failed acceptance gate. Preserve relevant error metadata, restore
the known-good VM snapshot or reapply a validated previous image to the test target.
For an existing user device, recover verified backups under an approved plan;
reimaging destroys local data. Roll back image/application changes by version, and
validate domain trust after recovery rather than assuming it survives restoration.

## PXE, WDS and MDT: documentation only

Conceptual flow: firmware PXE → isolated DHCP/PXE discovery → approved network boot
service → WinPE with NIC/storage drivers → deployment task → image/apply → drivers
and software → domain join → acceptance. Keep DHCP/PXE on the lab segment, control
which devices can boot, and protect image shares and deployment credentials.

MDT is a **legacy learning topic**: Microsoft retired it in January 2026. This
repository does not recommend a new MDT deployment or claim MDT, SCCM/Configuration
Manager, Intune or Autopilot hands-on experience. WDS workflows and current Windows
image support must be checked for the chosen OS; do not assume the old installation
media boot.wim workflow supports Windows 11. No WDS/PXE server is provisioned here.

References: [Sysprep overview](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--system-preparation--overview?view=windows-11),
[generalize an image](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation?view=windows-11),
[MDT retirement notice](https://github.com/MicrosoftDocs/SupportArticles-docs/blob/main/support/mem/configmgr/mdt/mdt-retirement.md).
