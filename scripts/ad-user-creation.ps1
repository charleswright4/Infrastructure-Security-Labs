<#
Purpose:
Create a new Active Directory user account.

Project:
Cisco IOS & Active Directory Hardening

Author:
Charles Wright
#>

Import-Module ActiveDirectory

New-ADUser `
    -Name "Test User" `
    -GivenName "Test" `
    -Surname "User" `
    -SamAccountName "tuser" `
    -Enabled $true `
    -AccountPassword (
        ConvertTo-SecureString `
        "Password123!" `
        -AsPlainText `
        -Force
    )
