#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Implements STIG WN11-SO-000025 (Built-in guest account must be renamed).

.DESCRIPTION
    Locates the built-in Guest account by its well-known RID (-501) and
    renames it to something other than "Guest".

    Use -AuditOnly to check compliance without making changes.
    Use -NewName to choose the new account name.

.EXAMPLE
    .\Set-WN11-SO-000025.ps1 -AuditOnly
    .\Set-WN11-SO-000025.ps1 -NewName 'VisitorAcct7'
#>

[CmdletBinding()]
param(
    [switch]$AuditOnly,

    # Pick a name that doesn't identify the account's purpose. Must not be "Guest".
    [ValidateScript({ $_ -ne 'Guest' })]
    [string]$NewName = 'LocalVisitor01'
)

$StigId = 'WN11-SO-000025'

try {
    $guest = Get-LocalUser -ErrorAction Stop |
             Where-Object { $_.SID.Value -match '^S-1-5-21-.+-501$' } |
             Select-Object -First 1
}
catch {
    Write-Error "[$StigId] Could not query local users: $_"
    return
}

if (-not $guest) {
    Write-Error "[$StigId] Built-in Guest account (RID 501) not found."
    return
}

if ($guest.Name -ne 'Guest') {
    Write-Host "[$StigId] COMPLIANT - built-in guest account is named '$($guest.Name)'" -ForegroundColor Green
    return
}

Write-Host "[$StigId] NON-COMPLIANT - built-in guest account is still named 'Guest'" -ForegroundColor Yellow

if ($AuditOnly) { return }

try {
    if (Get-LocalUser -Name $NewName -ErrorAction SilentlyContinue) {
        throw "An account named '$NewName' already exists. Choose a different -NewName."
    }

    Rename-LocalUser -SID $guest.SID -NewName $NewName -ErrorAction Stop

    $verify = Get-LocalUser -SID $guest.SID
    if ($verify.Name -ne 'Guest') {
        Write-Host "[$StigId] REMEDIATED - built-in guest account renamed to '$($verify.Name)'" -ForegroundColor Green
    }
    else {
        Write-Error "[$StigId] Verification failed. Account is still named 'Guest'."
    }
}
catch {
    Write-Error "[$StigId] Failed to rename account: $_"
}
