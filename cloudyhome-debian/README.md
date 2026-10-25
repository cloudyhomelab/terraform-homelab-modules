# cloudyhome-debian

Debian VM on Proxmox, configured by cloud-init, plus a Keycloak client for SSH host-certificate signing and an optional DNS A record.

## Prerequisites

- The disk image is on a storage of `config.node` as content type `iso` or `import`; the VM disk goes on `local-lvm` and the cloud-init snippets on `local` (snippets content enabled).
- The image ships `qemu-guest-agent`, and the `ssh-keysign` host-certificate client used by the default user cloud-init template.
- The `proxmox`, `keycloak` and `dns` providers are configured by the caller.

## Resources

- A confidential Keycloak OpenID client with a service account, named after the FQDN; the VM uses it to get its SSH host key signed.
- User and network cloud-init snippets on `local`.
- The VM, which boots on node start and waits for the guest agent to report an IPv4 address.
- With `create_dns_record`, an A record for `name` in `searchdomain`: the static address, or the DHCP address the guest agent reports.

## Inputs

| Name                      | Description | Required |
|---------------------------|-------------|----------|
| `config`                  | VM settings, see below. | yes |
| `image`                   | Disk image the VM disk is created from, see below. | yes |
| `age_secret`              | age private key, written to `/etc/homelab/age.key`. | yes |
| `ca_server_url`           | SSH CA server URL. | yes |
| `ca_sso_realm`            | Keycloak realm for the host-signing client. | yes |
| `ca_sso_token_url`        | Keycloak token endpoint for the client credentials. | yes |
| `user_cloud_init_file`    | Path to a replacement user cloud-init template (`.yml`/`.yaml`). | no |
| `network_cloud_init_file` | Path to a replacement network cloud-init template (`.yml`/`.yaml`). | no |

`config` attributes:

| Name                  | Description | Default |
|-----------------------|-------------|---------|
| `node`                | Proxmox node. | required |
| `name`                | VM name, hostname and DNS label. | required |
| `bridge`              | Bridge or SDN VNet for the network device. | required |
| `searchdomain`        | DNS domain of the FQDN, resolver search domain and zone of the A record. | required |
| `dhcp`                | Take the address from DHCP; `false` needs the static settings below. | required |
| `ip4_address_cidr`    | Static address in CIDR notation. | `null` |
| `gateway`             | Static default gateway. | `null` |
| `dns_addresses`       | Static DNS servers, one or two. | `[]` |
| `timezone`            | Guest time zone. | required |
| `username`, `user_id` | Login user with passwordless sudo, and its UID and GID. | required |
| `vmid`                | VM ID; `null` lets Proxmox assign one. | `null` |
| `description`         | VM description. | `""` |
| `bios`                | `seabios` or `ovmf`. | `seabios` |
| `cores`, `cpu`        | CPU cores and type. | `1`, `x86-64-v2-AES` |
| `memory`              | Memory in MiB. | `2048` |
| `disk_size`           | Disk size in GiB. | `10` |
| `keyboard_layout`     | Console keyboard layout. | `en-us` |
| `tags`                | Extra tags; `packer-debian` is always set. | `[]` |
| `create_dns_record`   | Create the A record in `searchdomain`. | `true` |
| `guest_agent_timeout` | How long to wait for the guest agent to report an IPv4 address. | `15m` |

`image` attributes:

| Name           | Description | Default |
|----------------|-------------|---------|
| `file_name`    | Disk image file name, looked up on `config.node` at plan time. | required |
| `content_type` | `import` or `iso`. | `import` |
| `datastore_id` | Storage holding the file. | `local` |

Changing `image` to another file recreates the VM from it.

### Custom cloud-init templates

Both templates are rendered with `templatefile`. The network template gets `config`; the user template gets `config`, `tags`, `fqdn`, `ca_server_url`, `ca_sso_client_id`, `ca_sso_client_secret`, `ca_sso_token_url` and `age_secret`.

## Outputs

| Name                | Description |
|---------------------|-------------|
| `vm_ipv4_address`   | Static address, or the DHCP address reported by the guest agent (null until reported). |
| `vm_ipv4_addresses` | IPv4 addresses per `en*` interface. |
| `vm_id`             | Proxmox VM ID. |
| `fqdn`              | `name` in `searchdomain`. |

## Usage

```hcl
module "debian" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-debian?ref=main"

  image = { file_name = "debian-runner-20261012-0837.qcow2" }

  ca_server_url    = var.ca_server_url
  ca_sso_realm     = var.ca_sso_realm
  ca_sso_token_url = var.ca_sso_token_url
  age_secret       = var.age_secret

  config = {
    node             = "pve"
    name             = "web01"
    bridge           = "vmbr0"
    searchdomain     = "home.example.com"
    dhcp             = false
    ip4_address_cidr = "192.0.2.10/24"
    gateway          = "192.0.2.1"
    dns_addresses    = ["192.0.2.1"]
    timezone         = "Europe/Helsinki"
    username         = "admin"
    user_id          = 1000
    tags             = ["web"]
  }
}
```
