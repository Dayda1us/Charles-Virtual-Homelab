# Charles' Homelab
## Description
The purpose of this repository is to document everything that I've done to my homelab and keep track of my learning progress.

**WARNING**: The scripts that I created are used only for testing/demonstration purposes. These scripts are NOT to be used in a production environment.

## Languages
As of November 2023, I'm currently using the following languages:
- PowerShell

Later on, I will be developing scripts using Ansible which will help me automate many tasks in a Linux environment.

## Homelab Setup
As of December 7, 2023, my homelab consists running VMware ESXi.

Specifications:
- CPU: Intel Core i7-10700
- RAM: 80 GB
- Storage: Crucial 1TB NVME SSD, 2TB Seagate HDD
- NIC: Intel Ethernet Network Adapter I350-T4

## Virtual Machines (VM)
List of Virtual Machines (VMs) that currently I run inside the ESXi server. (11/25/2023):
- (x2) Windows Server 2022 (One GUI, One core) running Active Directory, DHCP, and DNS
- (x4) Client PCs (2 Windows PCs, 2 Ubuntu PCs)
- (x1) VMware vCenter Server

All VMs were deployed with the help of Vagrant which automates the creation of the VMs which is very helpful whenever I destroy a system.

