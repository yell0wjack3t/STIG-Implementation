#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Implements STIG WN11-AU-000583 (Audit Handle Manipulation - Failure).

.DESCRIPTION
    Ensures Advanced Audit Policy > Object Access > Audit Handle Manipulation
    includes "Failure". Any existing Success setting is preserved
    (WN11-AU-000584 covers Success, so both can coexist).

    Uses the subcategory GUID so it works on any Windows display language.

    Use -AuditOnly to check compliance without making changes.

.EXAMPLE
    .\Set-WN11-AU-000583.ps1
    .\Set-WN11-AU-000583.ps1 -AuditOnly
#>

[CmdletBinding()]
param(
    [switch]$AuditOnly
)

$StigId  = 'WN11-AU-000583'
$SubGuid = '{0CCE9223-69AE-11D9-BED3-505054503030}'   # Object Access > Handle Manipulation

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

if (Test-HasFailure $current) {
    Write-Host "[$StigId] COMPLIANT - Handle Manipulation auditing = $current" -ForegroundColor Green
    return
}

Write-Host "[$StigId] NON-COMPLIANT - Handle Manipulation auditing = $current (expected to include Failure)" -ForegroundColor Yellow

if ($AuditOnly) { return }

try {
    $successState = if (Test-HasSuccess $current) { 'enable' } else { 'disable' }

    auditpol.exe /set /subcategory:"$SubGuid" /failure:enable /success:$successState | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "auditpol.exe exited with code $LASTEXITCODE" }

    $verify = Get-AuditSetting
    if (Test-HasFailure $verify) {
        Write-Host "[$StigId] REMEDIATED - Handle Manipulation auditing = $verify" -ForegroundColor Green
    }
    else {
        Write-Error "[$StigId] Verification failed. Current setting: $verify"
    }
}
catch {
    Write-Error "[$StigId] Failed to apply setting: $_"
}
