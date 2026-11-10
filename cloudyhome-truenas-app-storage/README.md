# cloudyhome-truenas-app-storage

TrueNAS datasets and NFS shares for the storage that images declare, each share allowing exactly the clients whose image uses it.

## Prerequisites

- The `truenas` provider is configured by the caller.
- The dataset `root` exists. It is not created here, as several callers may share it.

## Resources

- A dataset `<root>/<app>` per `app`, and `<root>/<app>/<dataset>` per `app` and `dataset` pair. Datasets belong to images, not clients: images naming the same pair share the dataset and must agree on its `recordsize`.
- An NFS share per pair dataset, commented with the image types using it, allowing only the addresses of the clients whose image names the pair (no networks), with root mapped to `root`.

Clients are allowed by address, never by name: the NFS server resolves names only when it loads the exports, so a DNS record added later stays unseen until mountd restarts. A client without an address fails the plan. The share owns its whole host list, so a client is added or removed by the next apply after it joins or leaves `clients`.

Every dataset has `prevent_destroy`, so neither dropping a pair nor destroying the caller deletes data; deleting a dataset is a manual step after removing it from state. Shares have no such guard, as they hold no data.

A dataset path has one owner. Two root modules naming the same pair would fight over the dataset and its share; neither can detect the other.

## Inputs

| Name      | Description | Required |
|-----------|-------------|----------|
| `root`    | Existing dataset holding the app datasets, without leading or trailing slash, e.g. `tank/app_data`. | yes |
| `images`  | Image key => `{type, storage}`; `storage` is a list of `{app, dataset, recordsize?}`, empty by default. | yes |
| `clients` | Client key => `{image, address}`; `image` is a key of `images`, `address` a bare IPv4 address or null when the client has none. Clients whose image needs no storage are ignored. | yes |

`app` and `dataset` must match `^[A-Za-z0-9_-][A-Za-z0-9._-]*$`; a `recordsize` left out inherits from the parent dataset.

## Outputs

| Name     | Description |
|----------|-------------|
| `shares` | Keyed by `<app>/<dataset>`: `dataset` (full dataset name), `path` (share path) and `hosts` (allowed addresses). |

## Usage

```hcl
module "app_storage" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-truenas-app-storage?ref=main"

  root = "tank/app_data"

  # The latest output of cloudyhome-proxmox-image-catalog fits this shape
  images = {
    "debian/debian-runner" = {
      type    = "debian-runner"
      storage = [{ app = "runner", dataset = "cache", recordsize = "1M" }]
    }
  }

  clients = {
    runner01 = { image = "debian/debian-runner", address = "192.0.2.10" }
  }
}
```
