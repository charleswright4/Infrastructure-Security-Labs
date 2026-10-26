# Azure Sentinel RDP Honeypot & Attack Map

## Overview

In this home lab project, I deployed a Windows virtual machine in Microsoft Azure and intentionally exposed Remote Desktop Protocol (RDP) services to the internet in order to attract unauthorized authentication attempts.

The goal was to collect real-world attack telemetry, ingest logs into Microsoft Sentinel, and visualize attacker activity using KQL queries and geolocation data.

---

## The Approach

A Windows virtual machine was deployed within Azure and configured to allow inbound RDP traffic.

Microsoft Sentinel was configured to collect security logs and monitor failed authentication attempts.

Using PowerShell and KQL, failed login events were analyzed and enriched with geolocation data to identify attack sources and patterns.

---

## Impact

This project demonstrates how a cloud-based SIEM can be used to collect logs, investigate suspicious activity, and provide visibility into real-world attack attempts against exposed systems.

---

## Azure Deployment

A Windows virtual machine was deployed within Azure and configured as a honeypot system.

![Azure Architecture](honeypot-architecture.jpg)

The VM was intentionally exposed to receive authentication attempts from external sources.

---

## Log Collection

Windows Security Event Logs were forwarded to Microsoft Sentinel for analysis.

![Log Collection](log-ingestion.jpg)

The collected logs provided visibility into failed login attempts and attacker behavior.

---

## Threat Investigation

KQL queries were used to identify failed login attempts and investigate attack patterns.

![KQL Investigation](kql-investigation.jpg)

Events were reviewed to determine attack frequency, source IP addresses, and authentication failures.

---

## Attack Visualization

Geolocation data was used to map failed login attempts.

![Attack Map](attack-map.jpg)

The attack map provided a visual representation of connection attempts and attack origins.

---

## Results

### Security Insights

- Real-world attack telemetry collected
- Failed authentication attempts analyzed
- Geolocation mapping completed
- Microsoft Sentinel dashboards created

### Outcome

The project successfully demonstrated cloud-based security monitoring, log analysis, threat hunting, and attack visualization using Microsoft Sentinel.

---

## Skills Demonstrated

- Microsoft Sentinel
- KQL
- SIEM Operations
- Threat Hunting
- Azure
- Log Analytics
- Security Monitoring
- Incident Investigation

---

## Lessons Learned

This project reinforced the importance of log visibility and continuous monitoring.

Without centralized logging and analysis, attack activity can go undetected even when systems are actively being targeted.
