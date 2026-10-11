# cloudyhome-proxmox-sdn

Proxmox SDN VLAN zones and their VNets, followed by an SDN apply so the configuration reaches the nodes. Another apply runs when the module is destroyed.

## Inputs

| Name     | Description | Required |
|----------|-------------|----------|
| `zones`  | VLAN zones keyed by zone ID, each mapping VNet ID to VLAN tag. | yes |
| `bridge` | Bridge, present on every node, that carries all zones, e.g. `vmbr0`. | yes |
| `ipam`   | IPAM plugin used by all zones. Default `pve`; `null` for none. | no |

Zone and VNet IDs are 2–8 alphanumeric characters starting with a letter. VNet IDs are cluster-wide, so they must be unique across zones. Every VNet is VLAN-aware, so guests can tag VLANs inside it.

## Outputs

| Name       | Description |
|------------|-------------|
| `zone_ids` | IDs of the created zones. |
| `vnet_ids` | VNet IDs keyed by themselves; available only after the SDN apply, so a VM using one as its bridge waits for it. |

## Usage

The network layout fits a small YAML (or JSON) file next to the root module:

```yaml
# sdn.yaml
Lab:
  IoTNet: 15
  LabNet: 16
VPN:
  IndiaNet: 200
```

```hcl
module "proxmox_sdn" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-proxmox-sdn?ref=main"
  bridge = "vmbr0"
  zones  = yamldecode(file("${path.module}/sdn.yaml"))
}
```

## Importing existing zones and VNets

Zones and VNets that already exist in Proxmox, e.g. created in the UI, must be imported before the first apply; otherwise the apply fails because they already exist. `import` blocks are only allowed in the root module, so add them next to the module call. Zone keys are the zone ID, VNet keys `<zone>-<vnet>`, and import IDs the plain zone or VNet ID:

```hcl
locals {
  sdn = yamldecode(file("${path.module}/sdn.yaml"))
}

import {
  for_each = local.sdn
  to       = module.proxmox_sdn.proxmox_sdn_zone_vlan.this[each.key]
  id       = each.key
}

import {
  for_each = merge([
    for zone, vnets in local.sdn : { for vnet in keys(vnets) : "${zone}-${vnet}" => vnet }
  ]...)
  to = module.proxmox_sdn.proxmox_sdn_vnet.this[each.key]
  id = each.value
}
```

Every object listed must already exist, so narrow the `for_each` when only some do. Imported VNets that are not VLAN-aware, or zones with a different bridge or IPAM, are updated in place on the first apply. Once imported, the blocks are no-ops and can stay.
