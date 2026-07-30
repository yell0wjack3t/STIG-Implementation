<#
.SYNOPSIS
    This PowerShell script ensures that autoplay is disabled for all drives

.NOTES
    Author          : Ashik Arif
    LinkedIn        : linkedin.com/in/ashikarif
    GitHub          : github.com/yell0wjack3t
    Date Created    : 2026-07-26
    Last Modified   : 2026-07-29
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000190
    Documentation   : https://stigaview.com/products/win11/v2r7/WN11-CC-000190/

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.


#>

# Requires Administrator
# WN11-CC-000190
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null

Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoDriveTypeAutoRun" `
    -Type DWord `
    -Value 255

Get-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoDriveTypeAutoRun"
