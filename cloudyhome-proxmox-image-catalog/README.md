# cloudyhome-proxmox-image-catalog

Downloads every build listed in published image indexes onto a Proxmox storage of every node in the cluster, as content type `import`, using [cloudyhome-proxmox-image](../cloudyhome-proxmox-image/README.md) per build.

Each image type publishes `<index_base_url>/<os>/<type>/index.json` with a `BUILDS` list; a build supplies `BUILD_VERSION`, `IMAGE_URL`, `IMAGE_FILE` and `IMAGE_CHECKSUM` (`<algorithm>:<hex>`). The indexes are read at plan time, so a build dropped from an index is deleted from the storage on the next apply.

## Inputs

| Name             | Description | Default |
|------------------|-------------|---------|
| `index_base_url` | Base URL under which the indexes are published. | required |
| `images`         | Image types to download, as lists of types keyed by OS. | required |
| `datastore_id`   | Storage the images are saved on; it must allow content type `import`. | `local` |

## Outputs

| Name     | Description |
|----------|-------------|
| `images` | Every build keyed by `<os>/<type>/<version>`: `os`, `type`, `version`, `file_name`, `file_ids` keyed by node, and `image`: `file_name`, `content_type` and `datastore_id`. |
| `latest` | Newest build of every image type keyed by `<os>/<type>`, in the same shape. |

## Usage

```yaml
# images.yaml
debian:
  - debian-runner
```

```hcl
module "images" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-proxmox-image-catalog?ref=main"

  index_base_url = "https://s3-api.cloudyhome.net/os-image-staging"
  images         = yamldecode(file("${path.module}/images.yaml"))
}

# module.images.latest["debian/debian-runner"].image
```
