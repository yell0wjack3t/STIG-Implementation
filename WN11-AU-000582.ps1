#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Implements STIG WN11-AU-000582 (Audit File System - Success).

.DESCRIPTION
    Ensures Advanced Audit Policy > Object Access > Audit File System
    includes "Success". Any existing Failure setting is preserved
    (WN11-AU-000581 requires Failure, so both can coexist).

    Uses the subcategory GUID so it works on any Windows display language.

    Use -AuditOnly to check compliance without making changes.

.EXAMPLE
    .\Set-WN11-AU-000582.ps1
    .\Set-WN11-AU-000582.ps1 -AuditOnly
#>

[CmdletBinding()]
param(
    [switch]$AuditOnly
)

$StigId  = 'WN11-AU-000582'
$SubGuid = '{0CCE921D-69AE-11D9-BED3-505054503030}'   # Object Access > File System

function Get-AuditSetting {
    $raw = auditpol.exe /get /subcategory:"$SubGuid" /r 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $raw) { return $null }
    $row = $raw | ConvertFrom-Csv | Select-Object -First 1
    return $row.'Inclusion Setting'
}

function Test-HasSuccess($s) { return ($null -ne $s -and $s -match 'Success') }
function Test-HasFailure($s) { return ($null -ne $s -and $s -match 'Failure') }

$current = Get-AuditSetting

if ($null -eq $current) {
    Write-Error "[$StigId] Could not read the audit policy via auditpol.exe."
    return
}

if (Test-HasSuccess $current) {
    Write-Host "[$StigId] COMPLIANT - File System auditing = $current" -ForegroundColor Green
    return
}

Write-Host "[$StigId] NON-COMPLIANT - File System auditing = $current (expected to include Success)" -ForegroundColor Yellow

if ($AuditOnly) { return }

try {
    $failureState = if (Test-HasFailure $current) { 'enable' } else { 'disable' }

    auditpol.exe /set /subcategory:"$SubGuid" /success:enable /failure:$failureState | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "auditpol.exe exited with code $LASTEXITCODE" }

    $verify = Get-AuditSetting
    if (Test-HasSuccess $verify) {
        Write-Host "[$StigId] REMEDIATED - File System auditing = $verify" -ForegroundColor Green
    }
    else {
        Write-Error "[$StigId] Verification failed. Current setting: $verify"
    }
}
catch {
    Write-Error "[$StigId] Failed to apply setting: $_"
}
