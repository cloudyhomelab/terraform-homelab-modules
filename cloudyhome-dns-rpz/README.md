# cloudyhome-dns-rpz

Allow and deny entries in DNS response policy zones (RPZ), managed through RFC 2136 dynamic updates.

## Prerequisites

- `allow_zone` and `deny_zone` exist on the DNS server and accept dynamic updates.
- The allow zone is listed before the deny zone in the server's `response-policy`; the first matching zone wins, so allow entries override deny entries.
- The `dns` provider is configured by the caller.

## Resources

- Per `allow` entry: `<name> CNAME rpz-passthru.` in `allow_zone`, exactly as given; a leading `*.` passes all subdomains.
- Per `deny` entry: `<domain> CNAME .` and `*.<domain> CNAME .` in `deny_zone`, answering NXDOMAIN for the domain and all its subdomains.

A call rejects inputs that write the same record name to both zones, e.g. allow `*.example.com` with deny `example.com`. Separate calls are not checked against each other; two calls writing the same name overwrite each other's record.

## Inputs

| Name     | Description | Required |
|----------|-------------|----------|
| `config` | Zones and entries, see below. | yes |

`config` attributes:

| Name         | Description | Default |
|--------------|-------------|---------|
| `allow_zone` | Allow zone, with or without trailing dot. | required |
| `deny_zone`  | Deny zone, with or without trailing dot. | required |
| `allow`      | Lowercase names without trailing dot, optionally starting with `*.`. | `[]` |
| `deny`       | Lowercase domains without trailing dot or `*.` prefix. | `[]` |
| `ttl`        | TTL of every record in seconds. | `300` |

## Outputs

| Name          | Description |
|---------------|-------------|
| `allow_fqdns` | Sorted fully qualified names of the allow records, with trailing dot. |
| `deny_fqdns`  | Sorted fully qualified names of the deny records, including wildcards, with trailing dot. |

## Usage

Block `example.com` and all its subdomains except `cdn.example.com`:

```hcl
module "rpz" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-dns-rpz?ref=main"

  config = {
    allow_zone = "rpz.allow"
    deny_zone  = "rpz.deny"
    allow      = ["cdn.example.com"]
    deny       = ["example.com"]
  }
}
```
