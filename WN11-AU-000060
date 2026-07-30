<#
.SYNOPSIS
    This PowerShell script ensures that the system is configured to audit Logon/Logoff - Group membership successes

.NOTES
    Author          : Ashik Arif
    LinkedIn        : linkedin.com/in/ashikarif
    GitHub          : github.com/yell0wjack3t
    Date Created    : 2026-07-26
    Last Modified   : 2026-07-29
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-AU-000060
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-AU-000060/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.


#>

# Requires Administrator

Write-Host "Applying WN11-AU-000060..." -ForegroundColor Cyan


# Enable Advanced Audit Policy
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

New-ItemProperty `
    -Path $RegPath `
    -Name "SCENoApplyLegacyAuditPolicy" `
    -Value 1 `
    -PropertyType DWORD `
    -Force | Out-Null


# Configure Group Membership auditing
auditpol.exe /set `
    /subcategory:"Group Membership" `
    /success:enable `
    /failure:disable | Out-Null


# Validation

$Result = auditpol.exe /get /subcategory:"Group Membership"

Write-Host "`nCurrent Setting:" -ForegroundColor Cyan
$Result


if ($Result -match "Success") {
    Write-Host "`nPASS: WN11-AU-000060 configured." -ForegroundColor Green
}
else {
    Write-Host "`nFAIL: WN11-AU-000060 failed." -ForegroundColor Red
}
