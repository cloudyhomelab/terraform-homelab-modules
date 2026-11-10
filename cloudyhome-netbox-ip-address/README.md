# cloudyhome-netbox-ip-address

IPv4 address for a host registered in NetBox, with the gateway and DNS servers of its VLAN, all looked up by the VLAN name.

## Prerequisites

- The `netbox` provider is configured by the caller.
- The VLAN named `network` has exactly one prefix.
- The prefix has the custom fields `gateway` (object) and `dns_servers` (multiobject), both pointing at IP address records.
- Without `ip4_address_cidr`: the prefix holds exactly one active IP range with role `static`, with the prefix's mask.

## Resources

- `ip4_address_cidr` given: that address, which must lie in the VLAN's prefix with the prefix's mask.
- `ip4_address_cidr` null: the next free address in the prefix's static range.

Either way the address is created with status `active` and `dns_name` recorded on it.

## Inputs

| Name     | Description | Required |
|----------|-------------|----------|
| `config` | Host settings, see below. | yes |

`config` attributes:

| Name               | Description | Default |
|--------------------|-------------|---------|
| `network`          | Name of the VLAN in NetBox the host attaches to. | required |
| `dns_name`         | FQDN recorded on the address in NetBox. | required |
| `ip4_address_cidr` | Address to register, with mask, e.g. `192.0.2.10/24`; null allocates one from the static range. | `null` |

## Outputs

| Name               | Description |
|--------------------|-------------|
| `ip4_address_cidr` | The host's address with mask, as registered in NetBox. |
| `gateway`          | Gateway of the VLAN's prefix, without mask. |
| `dns_addresses`    | DNS servers of the VLAN's prefix, without mask, in the order NetBox lists them. |

`dns_addresses` does not follow the order the field was set in, so it cannot express a primary DNS server.

## Usage

```hcl
module "address" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-netbox-ip-address?ref=main"

  config = {
    network  = "servers"
    dns_name = "web01.home.example.com"
  }
}
```
