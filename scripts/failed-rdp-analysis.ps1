<#
Purpose:
Review Windows Security logs for failed RDP authentication attempts.

Project:
Azure Sentinel RDP Honeypot & Attack Map

Author:
Charles Wright
#>

Get-WinEvent `
    -LogName Security `
    -MaxEvents 500 |
Where-Object {
    $_.Id -eq 4625
} |
Select-Object `
    TimeCreated,
    Id,
    MachineName
