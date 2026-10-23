<#
.SYNOPSIS
Performs scoped Active Directory lab operations with explicit change approval.
.DESCRIPTION
Creates a fixed lab OU hierarchy and groups, imports approved CSV users, manages
account state, or reads membership. Never creates privileged group membership.
Requires RSAT and delegated access. No passwords are accepted as plain text.
Changes only the selected objects under OU=Lab within the supplied domain.
Offboarding disables the account and removes only managed lab role groups;
it does not revoke cloud sessions, delete mail, or remove external access.
All mutations support WhatIf. Failures are terminating and logged without payloads.
.PARAMETER Action
Initialize, CreateUser, ImportUsers, AddMember, ResetPassword, Unlock, Disable, or Inspect.
.PARAMETER BaseDN
Directory naming context; the default is fictional.
.PARAMETER Server
Explicit domain controller to avoid using the operator's current domain by accident.
.PARAMETER Identity
Lab sAMAccountName for single-user operations.
.PARAMETER InitialPassword
SecureString supplied interactively for creation or reset. Required only on apply.
.EXAMPLE
./Invoke-LabDirectory.ps1 -Action Initialize -Server DC01.corp.example.test -WhatIf
.EXAMPLE
./Invoke-LabDirectory.ps1 -Action ImportUsers -Server DC01.corp.example.test -CsvPath ./sample-data/users.csv -WhatIf
.EXAMPLE
$secret = Read-Host 'Temporary lab password' -AsSecureString
./Invoke-LabDirectory.ps1 -Action ResetPassword -Server DC01.corp.example.test -Identity alex.river -InitialPassword $secret
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory)][ValidateSet('Initialize','CreateUser','ImportUsers','AddMember','ResetPassword','Unlock','Disable','Inspect')][string]$Action,
    [ValidatePattern('^DC=[A-Za-z0-9-]+(,DC=[A-Za-z0-9-]+)+$')][string]$BaseDN = 'DC=corp,DC=example,DC=test',
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9.-]+$')][string]$Server,
    [ValidatePattern('^[a-z][a-z0-9.-]{1,19}$')][string]$Identity,
    [ValidatePattern('^[A-Za-z][A-Za-z -]{0,49}$')][string]$GivenName,
    [ValidatePattern('^[A-Za-z][A-Za-z -]{0,49}$')][string]$Surname,
    [ValidateSet('Operations','Finance')][string]$Department = 'Operations',
    [ValidateSet('GG_Operations','GG_Finance')][string]$Group = 'GG_Operations',
    [ValidateNotNullOrEmpty()][string]$CsvPath = './sample-data/users.csv',
    [Security.SecureString]$InitialPassword,
    [ValidateNotNullOrEmpty()][string]$LogPath = './outputs/directory.log'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot/../common/Lab.Common.psm1" -Force
$labDN = "OU=Lab,$BaseDN"
$userDN = "OU=Users,$labDN"
$groupDN = "OU=Groups,$labDN"
$managedGroups = @('GG_Operations','GG_Finance')
try {
    Assert-LabWindows
    Import-Module ActiveDirectory -ErrorAction Stop
    if ((Get-ADDomain -Server $Server).DistinguishedName -ne $BaseDN) { throw 'Server domain does not match BaseDN.' }
    if ($Action -eq 'Initialize') {
        $ous = @(
            @{ Name = 'Lab'; Path = $BaseDN },
            @{ Name = 'Users'; Path = $labDN },
            @{ Name = 'Computers'; Path = $labDN },
            @{ Name = 'Groups'; Path = $labDN }
        )
        foreach ($ou in $ous) {
            $dn = 'OU={0},{1}' -f $ou.Name, $ou.Path
            $existing = @(Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$dn'" -Server $Server)
            if ($existing.Count -eq 0 -and $PSCmdlet.ShouldProcess($dn, 'Create protected lab OU')) {
                New-ADOrganizationalUnit @ou -ProtectedFromAccidentalDeletion $true -Server $Server
            }
        }
        foreach ($name in $managedGroups) {
            $existing = @(Get-ADGroup -Filter "SamAccountName -eq '$name'" -Server $Server)
            if ($existing.Count -gt 0 -and -not $existing[0].DistinguishedName.EndsWith(",$groupDN", [StringComparison]::OrdinalIgnoreCase)) { throw 'Group name exists outside managed OU.' }
            if ($existing.Count -eq 0 -and $PSCmdlet.ShouldProcess($name, 'Create global security group')) {
                New-ADGroup -Name $name -SamAccountName $name -GroupCategory Security -GroupScope Global -Path $groupDN -Server $Server
            }
        }
    } elseif ($Action -in @('CreateUser','ImportUsers')) {
        if ($Action -eq 'ImportUsers') {
            $rows = @(Import-Csv -LiteralPath $CsvPath)
        } else {
            if (-not $Identity -or -not $GivenName -or -not $Surname) { throw 'Identity, GivenName and Surname are required.' }
            $rows = @([pscustomobject]@{ SamAccountName = $Identity; GivenName = $GivenName; Surname = $Surname; Department = $Department; Group = $Group })
        }
        if ($rows.Count -eq 0) { throw 'CSV contains no users.' }
        $seen = @{}
        # Validate the entire batch before writing any accounts.
        foreach ($row in $rows) {
            foreach ($column in @('SamAccountName','GivenName','Surname','Department','Group')) {
                if (-not $row.PSObject.Properties[$column] -or [string]::IsNullOrWhiteSpace($row.$column)) { throw "Missing CSV field: $column" }
            }
            if ($row.SamAccountName -cnotmatch '^[a-z][a-z0-9.-]{1,19}$') { throw 'Invalid account name.' }
            if ($row.GivenName -notmatch '^[A-Za-z][A-Za-z -]{0,49}$' -or $row.Surname -notmatch '^[A-Za-z][A-Za-z -]{0,49}$') { throw 'Invalid display name.' }
            if ($row.Department -notin @('Operations','Finance') -or $row.Group -ne "GG_$($row.Department)") { throw 'Department and approved role group must match.' }
            if ($seen.ContainsKey($row.SamAccountName)) { throw 'Duplicate account in batch.' }
            $seen[$row.SamAccountName] = $true
            if (@(Get-ADUser -Filter "SamAccountName -eq '$($row.SamAccountName)'" -Server $Server).Count -gt 0) { throw 'Account already exists; review instead of overwriting.' }
            $target = Get-ADGroup -Identity $row.Group -Server $Server
            if (-not $target.DistinguishedName.EndsWith(",$groupDN", [StringComparison]::OrdinalIgnoreCase)) { throw 'Group is outside managed OU.' }
        }
        foreach ($row in $rows) {
            if ($PSCmdlet.ShouldProcess($row.SamAccountName, 'Create disabled user, assign role, then enable')) {
                if (-not $InitialPassword) { throw 'Provide InitialPassword as a SecureString.' }
                $upnDomain = ($BaseDN -replace 'DC=', '' -replace ',', '.')
                $created = New-ADUser -SamAccountName $row.SamAccountName -Name "$($row.GivenName) $($row.Surname)" -GivenName $row.GivenName -Surname $row.Surname -Department $row.Department -UserPrincipalName "$($row.SamAccountName)@$upnDomain" -Path $userDN -AccountPassword $InitialPassword -Enabled $false -ChangePasswordAtLogon $true -Server $Server -PassThru
                try {
                    Add-ADGroupMember -Identity $row.Group -Members $created -Server $Server
                    Enable-ADAccount -Identity $created -Server $Server
                } catch {
                    Disable-ADAccount -Identity $created -Server $Server
                    throw 'Provisioning incomplete; account left disabled. Review directory state before retrying.'
                }
            }
        }
    } else {
        if (-not $Identity) { throw 'Identity is required for this action.' }
        $user = Get-ADUser -Identity $Identity -Properties Enabled,LockedOut,MemberOf,PasswordLastSet -Server $Server
        if (-not $user.DistinguishedName.EndsWith(",$userDN", [StringComparison]::OrdinalIgnoreCase)) { throw 'Account is outside managed Users OU.' }
        switch ($Action) {
            'Inspect' {
                $user | Select-Object SamAccountName,DistinguishedName,Enabled,LockedOut,PasswordLastSet,MemberOf
                Get-ADPrincipalGroupMembership -Identity $user -Server $Server | Select-Object Name,GroupScope,GroupCategory
            }
            'AddMember' {
                $target = Get-ADGroup -Identity $Group -Server $Server
                if (-not $target.DistinguishedName.EndsWith(",$groupDN", [StringComparison]::OrdinalIgnoreCase)) { throw 'Group outside managed OU.' }
                if ($PSCmdlet.ShouldProcess($Identity, "Add to $Group")) { Add-ADGroupMember -Identity $target -Members $user -Server $Server }
            }
            'ResetPassword' {
                if ($PSCmdlet.ShouldProcess($Identity, 'Reset password and require change at logon')) {
                    if (-not $InitialPassword) { throw 'Provide InitialPassword as a SecureString.' }
                    Set-ADAccountPassword -Identity $user -Reset -NewPassword $InitialPassword -Server $Server
                    Set-ADUser -Identity $user -ChangePasswordAtLogon $true -Server $Server
                }
            }
            'Unlock' { if ($PSCmdlet.ShouldProcess($Identity, 'Unlock verified lab account')) { Unlock-ADAccount -Identity $user -Server $Server } }
            'Disable' {
                if ($PSCmdlet.ShouldProcess($Identity, 'Disable account and remove managed role memberships')) {
                    Disable-ADAccount -Identity $user -Server $Server
                    foreach ($name in $managedGroups) {
                        $target = Get-ADGroup -Identity $name -Server $Server
                        if (-not $target.DistinguishedName.EndsWith(",$groupDN", [StringComparison]::OrdinalIgnoreCase)) { throw 'Managed group is outside expected OU.' }
                        if ($user.MemberOf -contains $target.DistinguishedName) { Remove-ADGroupMember -Identity $target -Members $user -Confirm:$false -Server $Server }
                    }
                }
            }
        }
    }
    Write-LabLog -Message "Directory action completed: $Action; WhatIf=$WhatIfPreference" -Path $LogPath
} catch {
    Write-LabLog -Message "Directory action failed: $Action; inspect locally" -Path $LogPath
    throw
}
