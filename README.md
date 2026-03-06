# 🛠️ Debian 13 (Trixie) Workstation Automation

**Infrastructure as Code (IaC)** repository to transform a High-End Desktop into a professional **Virtualization Workstation** based on Debian 13.

This project replaces manual configurations with **Ansible**, providing idempotency and modularity for complex setups involving LVM-on-LUKS, KVM/Libvirt, and 2FA Security. The architecture is specifically optimized for the **Intel Core i9-13900K** and **ASUS ROG Z790 HERO** ecosystem, designed to safely coexist with a native Windows 11 Dual-Boot.

## ✨ Key Features & Intelligent Logic

Diferente de scripts comuns, este playbook inclui proteções de nível empresarial:

* **🧠 Detecção Inteligente de Ambiente**: O sistema identifica se está rodando em **Hardware Real** ou **Máquina Virtual (VirtualBox/KVM)**. Configurações críticas de rede (Bridges/VLANs) são ignoradas em VMs para evitar perda de conectividade.
* **🛡️ Validação de Hardware (Fail-Fast)**: Verifica se a Virtualização (VT-x) está ativa na BIOS antes de iniciar a instalação, evitando falhas silenciosas no KVM.
* **⚡ Snapshots Assíncronos**: O backup inicial via Timeshift é executado em modo assíncrono com *timeout* de 20 minutos, garantindo que o playbook não trave se o processo de disco demorar.
* **🚦 Auditoria de Saúde do Sistema**: Executa automaticamente `dpkg --configure -a` e `apt check` para corrigir instalações interrompidas antes de aplicar novas mudanças.
* **🔒 Segurança Multi-Fator (2FA)**: Implementação nativa de PAM para chaves físicas (Yubikey/FIDO2) integrada ao GNOME Login e Sudo.
* **🚀 Performance Tuning**: Perfil `tuned-adm` para Virtual Host, otimização de Swappiness (10), Inotify e limites de Log (Journald).

## ⚙️ Target Hardware

| Component | Model | Role |
| --- | --- | --- |
| **CPU** | Intel Core i9-13900K | Hybrid Arch (P-Cores/E-Cores) Tuning |
| **GPU** | NVIDIA GeForce RTX 3090 Ti | Host Native Acceleration (GNOME) |
| **RAM** | 64GB DDR5 | Performance Governor + VM Allocation |
| **SSD** | NVMe Gen4 512GB | **LVM-on-LUKS (OS + VM Logical Volumes)** |
| **Motherboard** | ASUS ROG MAXIMUS Z790 HERO | Virtualization & IOMMU Support |

## 📋 Prerequisites

### 1. BIOS Settings (Z790 Hero)
* **Secure Boot**: Enabled.
* **VT-d / VT-x**: **Enabled** (Obrigatório para o Playbook avançar).
* **Re-Size BAR**: Enabled.

### 2. Bootstrap (One-Liner de Instalação)
Em um Debian 13 recém-instalado, rode o comando abaixo para automatizar tudo (instalação do Ansible, Git e execução):

```bash
sudo apt update && sudo apt install -y ansible git && \
git clone [https://github.com/aleogr/debian-workstation.git](https://github.com/aleogr/debian-workstation.git) ~/workspace-debian && \
cd ~/workspace-debian && \
ansible-playbook -i inventory.ini playbook.yml -K

## 🚀 Usage

### 1. Configure Variables

Edite o arquivo `vars.yml`. Para a ASUS Z790 Hero, a interface física geralmente é `eno2` ou `enp3s0`.

```yaml
main_user: "aleogr"
physical_interface: "enp3s0"
vlan_id: 6
volume_group: "vg-debian"

```

### 2. Parâmetros de Execução

```bash
# Execução completa (Hardware Real)
ansible-playbook -i inventory.ini playbook.yml -K

# Teste em VirtualBox (Pula automaticamente tuning de HW e Rede complexa)
ansible-playbook -i inventory.ini playbook.yml -K

```

## 📂 Project Structure

```text
debian-automation/
├── roles/
│   ├── repository/     # Repositórios DEB822 e limpeza de fontes legadas
│   ├── system/         # Saúde do APT, Microcode, Swappiness, Inotify
│   ├── hardware/       # NVMe Latency & CPU Performance Mode
│   ├── security/       # PAM Hardening & Suporte a Chaves FIDO2
│   ├── desktop/        # GNOME 48 Minimal + GDM3
│   ├── virtualization/ # KVM/Libvirt + Validação de BIOS + LVM vms
│   ├── network/        # NetworkManager Bridge + VLAN (Modo Inteligente)
│   └── snapshots/      # Timeshift (Snapshot Inicial Assíncrono)

```

## ⚠️ Disclaimer

**Idempotência**: Você pode rodar este playbook múltiplas vezes. Ele apenas aplicará as mudanças se o sistema sair do estado desejado.
**Segurança de Disco**: O volume LVM `lv-vms` é criado apenas no espaço livre do VG especificado, protegendo outras partições (como Windows 11).

```



Boa sorte na sua nova workstation Z790! Gostaria que eu explicasse algum detalhe específico sobre como o suporte a chaves FIDO2 (2FA) foi implementado na role de segurança?

```
