#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Implements STIG WN11-CC-000335 (WinRM client must not allow unencrypted traffic).

.DESCRIPTION
    Sets:
      HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client
      AllowUnencryptedTraffic (REG_DWORD) = 0

    Use -AuditOnly to check compliance without making changes.

.EXAMPLE
    .\Set-WN11-CC-000335.ps1
    .\Set-WN11-CC-000335.ps1 -AuditOnly
#>

[CmdletBinding()]
param(
    [switch]$AuditOnly
)

$StigId       = 'WN11-CC-000335'
$RegPath      = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client'
$ValueName    = 'AllowUnencryptedTraffic'
$ExpectedData = 0
$ValueType    = 'DWord'

function Get-CurrentValue {
    try {
        (Get-ItemProperty -Path $RegPath -Name $ValueName -ErrorAction Stop).$ValueName
    }
    catch {
        $null
    }
}

$current = Get-CurrentValue

if ($current -eq $ExpectedData) {
    Write-Host "[$StigId] COMPLIANT - $ValueName = $current" -ForegroundColor Green
    return
}

$currentDisplay = if ($null -eq $current) { '<not set>' } else { $current }
Write-Host "[$StigId] NON-COMPLIANT - $ValueName = $currentDisplay (expected $ExpectedData)" -ForegroundColor Yellow

if ($AuditOnly) { return }

try {
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -Force | Out-Null
        Write-Verbose "Created registry key: $RegPath"
    }

    New-ItemProperty -Path $RegPath -Name $ValueName -Value $ExpectedData `
        -PropertyType $ValueType -Force | Out-Null

    $verify = Get-CurrentValue
    if ($verify -eq $ExpectedData) {
        Write-Host "[$StigId] REMEDIATED - $ValueName set to $verify" -ForegroundColor Green
    }
    else {
        Write-Error "[$StigId] Verification failed. Current value: $verify"
    }
}
catch {
    Write-Error "[$StigId] Failed to apply setting: $_"
}
