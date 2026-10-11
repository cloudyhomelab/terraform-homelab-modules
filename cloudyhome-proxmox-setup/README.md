# cloudyhome-proxmox-setup

Cluster-level Proxmox configuration:

- time zone of every node in the cluster
- content types of the default `local` directory storage and `local-lvm` LVM-thin storage
- Proxmox APT repositories on every node, as listed in `apt-repositories.json` (handle → enabled)

## Inputs

| Name       | Description                                       | Required |
|------------|---------------------------------------------------|----------|
| `timezone` | IANA time zone set on every node, e.g. `Europe/Helsinki`. | yes |

## Importing install-time objects

Proxmox creates some of the managed objects at install time, so they must be imported before the first apply; otherwise the apply fails because they already exist. `import` blocks are only allowed in the root module, so add them next to the module call. Once imported, the blocks are no-ops and can stay.

### Default storages

```hcl
module "proxmox_setup" {
  source   = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-proxmox-setup?ref=main"
  timezone = "Europe/Helsinki"
}

import {
  to = module.proxmox_setup.proxmox_storage_directory.this
  id = "local"
}

import {
  to = module.proxmox_setup.proxmox_storage_lvmthin.this
  id = "local-lvm"
}
```

Both storages have `prevent_destroy`, so any plan that would destroy or replace them fails, including removing the module. To stop managing them, drop them from state with a `removed` block or `terraform state rm`; the storages stay on Proxmox.

### Enterprise APT repositories

Every node ships with the `enterprise` and `ceph-squid-enterprise` repositories configured. Import them per node; resource keys are `<node>/<handle>` and import IDs `<node>,<handle>`:

```hcl
locals {
  proxmox_nodes                 = ["pve"]
  preinstalled_apt_repositories = ["enterprise", "ceph-squid-enterprise"]
}

import {
  for_each = {
    for pair in setproduct(local.proxmox_nodes, local.preinstalled_apt_repositories) :
    "${pair[0]}/${pair[1]}" => "${pair[0]},${pair[1]}"
  }
  to = module.proxmox_setup.proxmox_apt_standard_repository.this[each.key]
  id = each.value
}
```

When a node joins the cluster, add it to `proxmox_nodes` before the next apply.
