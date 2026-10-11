#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Implements STIG WN11-SO-000070 (Machine inactivity limit must be 15 minutes or less).

.DESCRIPTION
    Sets:
      HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
      InactivityTimeoutSecs (REG_DWORD) = 900

    Compliant if the value is between 1 and 900 seconds (0 is NOT compliant,
    since it disables the limit).

    Use -AuditOnly to check compliance without making changes.

.EXAMPLE
    .\Set-WN11-SO-000070.ps1
    .\Set-WN11-SO-000070.ps1 -AuditOnly
#>

[CmdletBinding()]
param(
    [switch]$AuditOnly
)

$StigId       = 'WN11-SO-000070'
$RegPath      = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$ValueName    = 'InactivityTimeoutSecs'
$SetData      = 900      # value written during remediation (15 minutes)
$MaxAllowed   = 900
$ValueType    = 'DWord'

function Get-CurrentValue {
    try {
        (Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop).$ValueName
    }
    catch {
        $null
    }
}

function Test-Compliant($v) {
    return ($null -ne $v -and $v -ge 1 -and $v -le $MaxAllowed)
}

$current = Get-CurrentValue

if (Test-Compliant $current) {
    Write-Host "[$StigId] COMPLIANT - $ValueName = $current" -ForegroundColor Green
    return
}

$currentDisplay = if ($null -eq $current) { '<not set>' } else { $current }
Write-Host "[$StigId] NON-COMPLIANT - $ValueName = $currentDisplay (expected 1-$MaxAllowed)" -ForegroundColor Yellow

if ($AuditOnly) { return }

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
        Write-Verbose "Created registry key: $RegPath"
    }

    New-ItemProperty -Path $RegPath -Name $ValueName -Value $SetData `
        -PropertyType $ValueType -Force | Out-Null

    $verify = Get-CurrentValue
    if (Test-Compliant $verify) {
        Write-Host "[$StigId] REMEDIATED - $ValueName set to $verify" -ForegroundColor Green
    }
    else {
        Write-Error "[$StigId] Verification failed. Current value: $verify"
    }
}
catch {
    Write-Error "[$StigId] Failed to apply setting: $_"
}
