# Network & Identity Hardening Lab (Cisco IOS + Active Directory GPO)

## Overview
Two parts of one lab: (1) securing a Cisco switch with VLAN segmentation, port security, and SSH-only management, and (2) building an Active Directory structure with Group Policy enforcing password, lockout, and firewall baselines. Built in a virtual lab; results below are from my own testing.

## Tools
Cisco Packet Tracer (free from Cisco NetAcad) or GNS3 | Windows Server 2022 evaluation VM (Hyper-V/VirtualBox/Azure) | PowerShell | Group Policy

---

## Part 1: Cisco Switch Hardening

### Topology
![Switch topology](images/network-topology.svg)


### Configuration
```text
enable
configure terminal
hostname SW1
ip domain-name lab.local

! VLANs
vlan 10
 name Management
vlan 20
 name Corporate-Data
exit

! Access port with port security
interface GigabitEthernet0/1
 switchport mode access
 switchport access vlan 20
 switchport port-security
 switchport port-security maximum 1
 switchport port-security mac-address sticky
 switchport port-security violation shutdown
 exit

! Admin port in the Management VLAN
interface GigabitEthernet0/24
 switchport mode access
 switchport access vlan 10
 exit

! Management SVI
interface vlan 10
 ip address 192.168.10.2 255.255.255.0
 no shutdown
 exit

! SSH v2 only
username admin secret StrongLabPass!2026
crypto key generate rsa modulus 2048
ip ssh version 2
line vty 0 4
 login local
 transport input ssh
 exit

enable secret StrongEnablePass!2026
service password-encryption
end
write memory
```

### Verification
```text
show vlan brief
show port-security interface GigabitEthernet0/1
show ip ssh
```


**Test:** Connect a second device to Gi0/1. Because port security allows one MAC and the violation mode is `shutdown`, the port should go err-disabled. Confirm with `show interfaces status err-disabled`.

---

## Part 2: Active Directory & Group Policy

### Step 1: Build the Domain
Install the AD DS role on Windows Server and promote to a new forest (e.g. `lab.local`).

![AD OU and GPO structure](images/ad-structure.svg)

### Step 2: Create OUs and Users
```powershell
$base = "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "Corp"        -Path $base
New-ADOrganizationalUnit -Name "Users"       -Path "OU=Corp,$base"
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Corp,$base"
New-ADOrganizationalUnit -Name "Admins"      -Path "OU=Corp,$base"
```

### Step 3: Password and Lockout Policy
```powershell
Set-ADDefaultDomainPasswordPolicy -Identity lab.local `
  -MinPasswordLength 14 -ComplexityEnabled $true `
  -LockoutThreshold 5 -LockoutDuration 00:30:00 -LockoutObservationWindow 00:30:00
```

### Step 4: Firewall GPO
Group Policy Management → create a GPO linked to `Workstations` → Computer Configuration → Windows Settings → Security Settings → Windows Defender Firewall → enable Domain, Private, and Public profiles.

### Step 5: Verify
```powershell
Get-ADDefaultDomainPasswordPolicy
Get-ADOrganizationalUnit -Filter * | Select Name, DistinguishedName
gpresult /r
```


## Verification Checklist
- `show port-security interface Gi0/1` shows maximum 1 and a learned sticky MAC.
- `show ip ssh` reports SSH version 2; Telnet is refused.
- `Get-ADDefaultDomainPasswordPolicy` returns the 14-character minimum and lockout settings.
- `gpresult /r` on a joined workstation lists the firewall GPO as applied.

## Key Takeaways
- Segmenting management from user traffic limits what a compromised endpoint can reach.
- Port security stops unauthorized devices at the access layer.
- Group Policy enforces a baseline consistently instead of machine by machine.
