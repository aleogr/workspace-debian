# 🛠️ Debian 13 (Trixie) Workstation Automation

**Infrastructure as Code (IaC)** repository to transform a High-End Desktop into a professional **Virtualization Workstation** based on Debian 13.

This project replaces manual configurations with **Ansible**, providing idempotency and modularity for complex setups involving LVM-on-LUKS, KVM/Libvirt, and 2FA Security. The architecture is specifically optimized for the **Intel Core i9-13900K** and **ASUS ROG Z790 HERO** ecosystem, designed to safely coexist with a native Windows 11 Dual-Boot.

## ⚙️ Target Hardware

Developed and tested on the following high-performance specifications:

| Component | Model | Role |
| --- | --- | --- |
| **CPU** | Intel Core i9-13900K | Hybrid Arch (P-Cores/E-Cores) Tuning |
| **GPU** | NVIDIA GeForce RTX 3090 Ti | Host Native Acceleration (GNOME) |
| **RAM** | 64GB DDR5 | Performance Governor + VM Allocation |
| **SSD** | NVMe Gen4 512GB | **LVM-on-LUKS (OS + VM Logical Volumes)** |
| **Motherboard** | ASUS ROG MAXIMUS Z790 HERO | Virtualization & IOMMU |
| **Networking** | Intel® 2.5Gb Ethernet (eno2) | VLAN 6 Tagged Bridge (UniFi) |

## 📋 Prerequisites

### 1. BIOS Settings (Dual-Boot & Security Friendly)

* **Secure Boot:** **Enabled** (Compatible with Debian 13 and Windows 11).
* **VT-d / VT-x:** **Enabled** (Required for KVM/QEMU).
* **Primary Display:** **PEG / PCIe GPU**.
* **Re-Size BAR:** **Enabled**.

### 2. Bootstrap (On Fresh Debian 13)

Install Ansible and Git on your local machine:

```bash
sudo apt update && sudo apt install -y ansible git

```

### 3. Clone Repository

```bash
git clone https://github.com/aleogr/debian-workstation.git
cd debian-workstation

```

## 🚀 Usage

### 1. Configure Variables

Edit the `vars.yml` file. This file centralizes your hardware-specific names. For this specific hardware, ensure `physical_interface` is set to `eno2`.

```yaml
main_user: "aleogr"
physical_interface: "eno2"
vlan_id: 6
volume_group: "vg-debian"

```

### 2. Run the Playbook

The script will prompt you for your **Main User Password**. This password will be securely hashed (SHA512) and applied to your Linux account.

```bash
# Full execution (Physical Hardware)
ansible-playbook -i inventory.ini playbook.yml -K

# Run in VirtualBox (Skips NVMe/CPU performance tuning)
ansible-playbook -i inventory.ini playbook.yml -K --skip-tags "hw"

```

## 📂 Project Structure

```text
debian-automation/
├── inventory.ini         # Localhost connection definition
├── playbook.yml          # Main Playbook (Orchestration)
├── vars.yml              # Global Variables (Interfaces, Codename, LVM)
└── roles/                # Modular Tasks & Handlers
    ├── repository/       # "Scorched Earth" APT policy & DEB822 sources
    ├── system/           # Intel-Microcode, Swappiness, Inotify, Journald
    ├── hardware/         # NVMe Gen4 Latency Fix, CPU Performance mode
    ├── security/         # PAM Hardening, YubiKey U2F Centralized Auth
    ├── desktop/          # Minimal GNOME Shell environment
    ├── virtualization/   # KVM, Libvirt stack, 100% FREE LVM allocation
    ├── network/          # NetworkManager Bridge + VLAN 6 (eno2)
    └── snapshots/        # Timeshift automated recovery points

```

## ✋ Security & Manual Steps

### 1. Password Hardening

The `security` role enforces **PAM Password Quality**. New passwords must be at least **12 characters** long and include Uppercase, Lowercase, Numbers, and Symbols.

### 2. Registering YubiKeys

Authentication via YubiKey is prepared but not enforced until you register your keys. To enable 2FA for Sudo and Login:

```bash
# Create the entry for your user in the centralized mapping file
pamu2fcfg -u aleogr | sudo tee -a /etc/Yubico/u2f_mappings

```

Once at least one key is present in `/etc/Yubico/u2f_mappings`, the system will automatically require the YubiKey touch for Sudo and GDM login.

## ⚠️ Disclaimer

**Idempotency:** This playbook is idempotent. You can run it multiple times to ensure your system stays in the desired state.

**Disk Safety:** The `virtualization` role creates a Logical Volume (`lv-vms`) inside your existing Volume Group. It does **not** touch secondary physical disks, keeping your Windows 11 partition safe.
