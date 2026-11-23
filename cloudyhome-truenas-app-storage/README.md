# cloudyhome-truenas-app-storage

TrueNAS datasets for the storage each client declares, and NFS shares allowing exactly the clients that have an address.

## Prerequisites

- The `truenas` provider is configured by the caller.
- The dataset `root` exists. It is not created here, as several callers may share it.

## Resources

- A dataset `<root>/<app>` per `app`, and `<root>/<app>/<dataset>` per `app` and `dataset` pair, for every client with or without an address. Clients naming the same pair share the dataset and must agree on its `recordsize`.
- An NFS share per pair dataset while at least one of its clients has an address, allowing exactly those addresses (no networks), with root mapped to `root` and the clients' keys as comment.

Datasets and shares are keyed by pair, never by client: renaming a client moves nothing, and the client key only labels errors and the share comment.

A client without an address keeps its data and has no access. Removing the last addressed client of a pair removes its share, never its dataset.

Clients are allowed by address, never by name: the NFS server resolves names only when it loads the exports, so a DNS record added later stays unseen until mountd restarts. The share owns its whole host list, so a client gains or loses access on the next apply after its address is set or removed.

Every dataset has `prevent_destroy`, so neither dropping a pair nor destroying the caller deletes data; deleting a dataset is a manual step after removing it from state. Shares have no such guard, as they hold no data.

A dataset path has one owner. Two root modules naming the same pair would fight over the dataset and its share; neither can detect the other.

## Inputs

| Name      | Description | Required |
|-----------|-------------|----------|
| `root`    | Existing dataset holding the app datasets, without leading or trailing slash, e.g. `tank/app_data`. | yes |
| `clients` | Client key => `{storage, address}`; `storage` is a list of `{app, dataset, recordsize?}`, `address` a bare IPv4 address, left out when the client has none. | yes |

`app` and `dataset` must match `^[A-Za-z0-9_-][A-Za-z0-9._-]*$`; a `recordsize` left out inherits from the parent dataset.

## Outputs

| Name     | Description |
|----------|-------------|
| `shares` | Keyed by `<app>/<dataset>` for pairs with an addressed client: `dataset` (full dataset name), `path` (share path) and `hosts` (allowed addresses). |

## Usage

```hcl
module "app_storage" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-truenas-app-storage?ref=main"

  root = "tank/app_data"

  clients = {
    runner01 = {
      storage = [{ app = "runner", dataset = "cache", recordsize = "1M" }]
      address = "192.0.2.10"
    }
    # Keeps runner/cache, no access
    runner02 = {
      storage = [{ app = "runner", dataset = "cache", recordsize = "1M" }]
    }
  }
}
```
