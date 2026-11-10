# terraform-homelab-modules

OpenTofu modules for a Proxmox-based homelab. Each module is used from its subdirectory:

```hcl
source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//<module>?ref=main"
```

## Modules

| Module | Purpose |
|--------|---------|
| [cloudyhome-proxmox-init](cloudyhome-proxmox-init/README.md) | Proxmox user, role and API token for OpenTofu. |
| [cloudyhome-proxmox-setup](cloudyhome-proxmox-setup/README.md) | Cluster-level Proxmox configuration: time zone, default storages, APT repositories. |
| [cloudyhome-proxmox-sdn](cloudyhome-proxmox-sdn/README.md) | SDN VLAN zones and VNets. |
| [cloudyhome-proxmox-image](cloudyhome-proxmox-image/README.md) | ISO, disk image or container template downloaded onto node storage. |
| [cloudyhome-proxmox-image-catalog](cloudyhome-proxmox-image-catalog/README.md) | Builds listed in published image indexes downloaded onto node storage. |
| [cloudyhome-debian](cloudyhome-debian/README.md) | Debian VM configured by cloud-init. |
| [cloudyhome-ha](cloudyhome-ha/README.md) | Home Assistant OS VM. |
| [cloudyhome-dns-record](cloudyhome-dns-record/README.md) | DNS A record and matching PTR record for a host. |
| [cloudyhome-netbox-ip-address](cloudyhome-netbox-ip-address/README.md) | Host IPv4 address registered in NetBox, with the gateway and DNS servers of its VLAN. |
| [cloudyhome-truenas-app-storage](cloudyhome-truenas-app-storage/README.md) | TrueNAS datasets and NFS shares for the storage images declare, limited to the clients using them. |
