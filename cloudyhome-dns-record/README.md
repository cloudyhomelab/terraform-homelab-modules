# cloudyhome-dns-record

A record for a host and the matching PTR record, managed through RFC 2136 dynamic updates.

## Prerequisites

- `zone` and `reverse_zone` exist on the DNS server and accept dynamic updates.
- The `dns` provider is configured by the caller.

## Resources

- An A record for `name` in `zone`, pointing at `ipv4`.
- A PTR record for `ipv4` in `reverse_zone`, pointing at the FQDN.

The records depend only on the inputs. To create them before the host exists, pass an address that does not reference the host's resources: OpenTofu orders by every reference in an expression, including the unused branch of a conditional.

## Inputs

| Name     | Description | Required |
|----------|-------------|----------|
| `config` | Host settings, see below. | yes |

`config` attributes:

| Name           | Description | Default |
|----------------|-------------|---------|
| `name`         | Host label, relative to `zone`. | required |
| `zone`         | Forward zone, with or without trailing dot. | required |
| `ipv4`         | Host address; may be unknown at plan time, but must be known at apply. | required |
| `reverse_zone` | `in-addr.arpa` zone that holds `ipv4`, e.g. `2.0.192.in-addr.arpa`; it may cover a /8, /16 or /24. | required |
| `ttl`          | TTL of both records in seconds. | `300` |

## Outputs

| Name       | Description |
|------------|-------------|
| `fqdn`     | `name` in `zone`, with trailing dot. |
| `ptr_fqdn` | Fully qualified name of the PTR record, with trailing dot, e.g. `10.2.0.192.in-addr.arpa.`. |

## Usage

```hcl
module "dns" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-dns-record?ref=main"

  config = {
    name         = "web01"
    zone         = "home.example.com"
    ipv4         = "192.0.2.10"
    reverse_zone = "2.0.192.in-addr.arpa"
  }
}
```
