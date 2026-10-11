# terraform-homelab-modules

Terraform modules for a Proxmox-based homelab. Each module is used from its subdirectory:

```hcl
source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//<module>?ref=main"
```

## Modules

| Module | Purpose |
|--------|---------|
| [cloudyhome-proxmox-init](cloudyhome-proxmox-init/README.md) | Proxmox user, role and API token for Terraform. |
| [cloudyhome-proxmox-setup](cloudyhome-proxmox-setup/README.md) | Cluster-level Proxmox configuration: time zone, default storages, APT repositories. |
| [cloudyhome-proxmox-sdn](cloudyhome-proxmox-sdn/README.md) | SDN VLAN zones and VNets. |
| [cloudyhome-debian](cloudyhome-debian/README.md) | Debian VM configured by cloud-init. |
| [cloudyhome-ha](cloudyhome-ha/README.md) | Home Assistant OS VM. |
