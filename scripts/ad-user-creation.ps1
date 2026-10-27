<#
Purpose:
Create a new Active Directory user account.

Project:
Cisco IOS & Active Directory Hardening

Author:
Charles Wright
#>



Import-Module ActiveDirectory

$Password = Read-Host "Enter temporary password" -AsSecureString

New-ADUser `
    -Name "Test User" `
    -GivenName "Test" `
    -Surname "User" `
    -SamAccountName "tuser" `
    -AccountPassword $Password `
    -ChangePasswordAtLogon $true `
    -Enabled $true
