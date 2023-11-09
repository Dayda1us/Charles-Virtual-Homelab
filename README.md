# Charles' Homelab
This repository documents all of my scripts that I developed for my homelab. 

As of November 2023, I'm currently using the following languages:
- PowerShell (Automating Microsoft environment)
- Python (Relarning. Will currently use for other environments such as Linux, etc.)

## Homelab Setup
As of November 9, 2023, my homelab consists of (x1) VMware ESXi server running on a Dell Optiplex 5080 Small Form Factor (SFF).
Specifications:
- CPU: Intel Core i7-10700
- RAM 80 GB
- Storage: Crucial 1TB NVME SSD
- NIC: Intel Ethernet Network Adapter I350-T4

Later on, I will upgrade the RAM to its maximum capacity (128GB) to ensure that I will be able to run as many virtual machines as I need.

Prior to that, back on October 13, 2023 I used to run an ESXi server on a Lenovo Thinkcentre M720Q.
Specifications:
- CPU: Intel Core i5 8500T
- RAM: 64GB
- Storage: 2TB NVME SSD
- NIC: Intel Ethernet Network Adapter I350-T4

Here is a list of Virtual Machines (VMs) that currently run inside the server. (10/18/2023):
- (x2) Active Directory servers both running Windows Server 2022 (One GUI, One core)
- (x4) Client PCs (4 Windows PCs, 4 Ubuntu PCs)
- (x1) Web Server (Rocky Linux)

## VM's Purpose
### Windows Server 2022
The two VM's running Windows Server 2022 has three roles installed. Those are:
- Active Directory Domain Services (AD DS)
- Domain Name Service (DNS) [Required for AD DS]
- DHCP Server
