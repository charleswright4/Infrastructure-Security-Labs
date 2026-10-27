<#
Purpose:
Disables insecure protocols and applies security hardening controls.

Project:
Enterprise Vulnerability Management & Remediation

Author:
Charles Wright
#>

# Disable SMBv1

Disable-WindowsOptionalFeature `
    -Online `
    -FeatureName SMB1Protocol `
    -NoRestart

# Enable Network Level Authentication

$RdpPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"

Set-ItemProperty `
    -Path $RdpPath `
    -Name UserAuthentication `
    -Value 1

Write-Host "Security hardening completed successfully."
