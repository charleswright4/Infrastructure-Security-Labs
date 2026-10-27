<#
Purpose:
Review Windows Security logs for failed RDP authentication attempts.

Project:
Azure Sentinel RDP Honeypot & Attack Map

Author:
Charles Wright
#>

Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 4625 } -MaxEvents 500 -ErrorAction SilentlyContinue |
Select-Object TimeCreated, Id, MachineName,
    @{Name = 'SourceIP'; Expression = { $_.Properties[19].Value }}
