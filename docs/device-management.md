# Asset and endpoint lifecycle

[Inventory](../assets/inventory.csv) is a fictional register, not discovered hardware.
Asset IDs and serial numbers are invented. Check-in timestamps are scenario data.
Warranty status must be verified with procurement/vendor records in a real service.

## Allocate a device

1. Link the approved onboarding request, asset ID and receiving employee.
2. Confirm available stock, warranty, hardware condition and compatible OS/license.
3. Deploy the approved image, drivers and applications; perform validation.
4. Verify encryption/recovery-key escrow through the lab's chosen process. Do not
   export recovery keys or include them in screenshots.
5. Assign the standard user, record handover and update status to Assigned/In service.
6. Confirm accessories, sign-in and user acceptance; record next check-in expectations.

## Return, replacement and disposal

On return, record custody transfer and accessories; set Returned/Assessment. Coordinate
data retention and authorized transfer before wiping. Remove access, inspect the
device and run approved sanitization with a recorded verification result. Reimage
and validate before returning to Available/Stock. Do not reuse a disk that failed
sanitization. For replacement, record old/new asset IDs and user acceptance; retain
the old device until migration is verified. For disposal, obtain approval, sanitize
or physically destroy media through an approved provider, retain certificate details
outside Git and set Retired/Disposed. Expired warranty alone does not imply disposal.

## Collection

```powershell
./scripts/device-management/Get-LabInventory.ps1 -WhatIf
./scripts/device-management/Get-LabInventory.ps1 -OutputPath ./outputs/WS01-inventory.json
```

The script reads CIM, IPv4 configuration and machine-wide uninstall registry keys.
It does not query `Win32_Product`, which can trigger installer repair. Per-user,
portable and Store applications may be missing. It collects logged-in user and IP
information locally; sanitize those fields before any publication. It does not
enroll devices in Intune/SCCM or implement remote management or software deployment.
