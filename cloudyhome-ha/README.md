# cloudyhome-ha

Home Assistant OS VM on Proxmox (UEFI, DHCP), plus an optional DNS A record for the address its guest agent reports.

## Prerequisites

- The disk image is on the node's `local` storage as content type `iso`; the VM disk and EFI disk go on `local-lvm`.
- The `proxmox` and `dns` providers are configured by the caller.

## Inputs

| Name         | Description | Required |
|--------------|-------------|----------|
| `config`     | VM settings, see below. | yes |
| `image_name` | Disk image file name on `local`. | yes |

`config` attributes:

| Name                  | Description | Default |
|-----------------------|-------------|---------|
| `node`                | Proxmox node. | required |
| `name`                | VM name and DNS label. | required |
| `bridge`              | Bridge or SDN VNet for the network device. | required |
| `vmid`                | VM ID; `null` lets Proxmox assign one. | `null` |
| `description`         | VM description. | `""` |
| `searchdomain`        | DNS domain of the FQDN and zone of the A record. | required |
| `create_dns_record`   | Create the A record in `searchdomain`. | `true` |
| `cores`, `cpu`        | CPU cores and type. | `1`, `x86-64-v2-AES` |
| `memory`              | Memory in MiB. | `2048` |
| `disk_size`           | Disk size in GiB. | `32` |
| `keyboard_layout`     | Console keyboard layout. | `en-us` |
| `tags`                | Extra tags; `home_assistant` is always set. | `[]` |
| `guest_agent_timeout` | How long to wait for the guest agent to report an IPv4 address. | `15m` |

## Outputs

| Name                | Description |
|---------------------|-------------|
| `vm_ipv4_address`   | DHCP address reported by the guest agent (null until reported). |
| `vm_ipv4_addresses` | IPv4 addresses per `en*` interface. |
| `vm_id`             | Proxmox VM ID. |
| `fqdn`              | `name` in `searchdomain`. |

## Usage

```hcl
module "home_assistant" {
  source     = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-ha?ref=main"
  image_name = "haos_ova-16.2.qcow2.img"

  config = {
    node         = "pve"
    name         = "homeassistant"
    bridge       = "IoTNet"
    searchdomain = "home.example.com"
    cores        = 2
    memory       = 4096
  }
}
```
