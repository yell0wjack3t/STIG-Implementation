<#
.SYNOPSIS
    This PowerShell script configures Windows 11 to audit Detailed File Share Failures.

.NOTES
    Author          : Ashik Arif
    LinkedIn        : linkedin.com/in/ashikarif
    GitHub          : github.com/yell0wjack3t
    Date Created    : 2026-07-29
    Last Modified   : 2026-07-29
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A

    STIG-ID         : WN11-AU-000570
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-AU-000570/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here. 
#>

# Requires Administrator

Write-Host "Applying WN11-AU-000570..." -ForegroundColor Cyan


# Configure Detailed File Share failure auditing

auditpol.exe /set `
    /subcategory:"Detailed File Share" `
    /failure:enable `
    /success:disable | Out-Null


# Validation

$Result = auditpol.exe /get /subcategory:"Detailed File Share"

Write-Host "`nCurrent Setting:" -ForegroundColor Cyan
$Result


if ($Result -match "Failure") {
    Write-Host "`nPASS: WN11-AU-000570 configured." -ForegroundColor Green
}
else {
    Write-Host "`nFAIL: WN11-AU-000570 failed." -ForegroundColor Red
}
