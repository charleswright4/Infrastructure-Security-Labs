# Cloud SIEM Lab: Azure Sentinel RDP Honeypot with Attack Map

## Overview
I deployed an intentionally exposed Windows VM in Azure, captured failed RDP logon attempts (Event ID 4625), enriched the source IPs with geolocation data using PowerShell, ingested the logs into Microsoft Sentinel, and plotted attack origins on a world map.

> ⚠️ **Safety:** Use a dedicated lab subscription, set a budget alert, and delete the resource group when finished. Never put real data or credentials on a honeypot.

## Tools
Microsoft Sentinel | Log Analytics Workspace | Azure VM (Windows) | PowerShell | ipgeolocation.io (free tier) | KQL

## Architecture
```text
Internet attackers --> Azure VM (RDP open) --> Event ID 4625
        --> PowerShell script + geolocation API --> failed_rdp.log
        --> Log Analytics custom log --> Sentinel workbook map
```

## Step 1: Build the Honeypot
1. Create a Windows VM; in its Network Security Group allow inbound RDP (3389) from `Any`.
2. Create a Log Analytics workspace and enable Microsoft Sentinel on it.
3. Connect the VM with the Azure Monitor Agent.
4. Turn off the Windows Firewall on the VM (lab only) so attempts are logged.

📸 **Screenshot:** NSG inbound rules → `images/01-nsg.png`

## Step 2: Confirm Attack Data in Event Viewer
After a few hours, open Event Viewer → Windows Logs → Security and filter for **4625**.

📸 **Screenshot:** Real 4625 events from your VM → `images/02-event-viewer.png`

## Step 3: Geolocation Script
Sign up for a free API key at ipgeolocation.io and paste it below. The script tracks processed event IDs so it doesn't re-log the same attempt.

```powershell
$API_KEY      = "YOUR_API_KEY_HERE"
$LOGFILE_PATH = "C:\ProgramData\failed_rdp.log"
$seen         = New-Object System.Collections.Generic.HashSet[long]

if (-not (Test-Path $LOGFILE_PATH)) { New-Item -ItemType File -Path $LOGFILE_PATH -Force | Out-Null }

Write-Host "[+] Starting RDP honeypot log exporter..." -ForegroundColor Cyan

while ($true) {
    $events = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 200 -ErrorAction SilentlyContinue
    foreach ($e in $events) {
        if (-not $seen.Add($e.RecordId)) { continue }

        $data = ([xml]$e.ToXml()).Event.EventData.Data
        $ip   = ($data | Where-Object Name -eq 'IpAddress').'#text'
        $user = ($data | Where-Object Name -eq 'TargetUserName').'#text'

        if ($ip -and $ip -ne '-') {
            $uri  = "https://api.ipgeolocation.io/ipgeo?apiKey=$API_KEY&ip=$ip"
            $resp = Invoke-RestMethod -Uri $uri -Method Get -ErrorAction SilentlyContinue
            if ($resp) {
                $line = "latitude:$($resp.latitude),longitude:$($resp.longitude),sourcehost:$ip,username:$user,country:$($resp.country_name),state:$($resp.state_prov),timestamp:$($e.TimeCreated.ToString('s'))"
                Add-Content -Path $LOGFILE_PATH -Value $line
                Write-Host "Logged -> $ip | $($resp.country_name)"
                Start-Sleep -Milliseconds 1200   # stay inside free-tier rate limits
            }
        }
    }
    Start-Sleep -Seconds 10
}
```

📸 **Screenshot:** Script output in PowerShell → `images/03-script.png`

## Step 4: Ingest and Map in Sentinel
1. Log Analytics workspace → Tables → Create → **New custom log (MMA-based)**, upload a sample of `failed_rdp.log`, set the path to `C:\ProgramData\failed_rdp.log`, and name it `FAILED_RDP_CL`. (Azure's custom-log options change often; follow the current prompts.)
2. Run this KQL:

```kql
FAILED_RDP_CL
| extend Latitude  = extract("latitude:([^,]+)", 1, RawData)
| extend Longitude = extract("longitude:([^,]+)", 1, RawData)
| extend SourceIp  = extract("sourcehost:([^,]+)", 1, RawData)
| extend Username  = extract("username:([^,]+)", 1, RawData)
| extend Country   = extract("country:([^,]+)", 1, RawData)
| summarize Attempts = count() by SourceIp, Country, Latitude, Longitude
| order by Attempts desc
```

3. Sentinel → Workbooks → New → Add query → set visualization to **Map**, using Latitude/Longitude and Attempts as size.

📸 **Screenshot:** Your real attack map → `images/04-attack-map.png`

## Results
- Run time: `[YOUR RESULT: e.g. 24 hours]`
- Total failed attempts: `[#]`
- Top source countries: `[YOUR RESULT]`
- Most targeted usernames: `[YOUR RESULT]`

## Takeaways
`[2-3 honest sentences: e.g. how quickly attacks began, why exposed RDP is risky, what controls you'd use in production such as NLA, MFA, VPN/Bastion]`

## Cleanup
Delete the resource group when done to stop charges.
