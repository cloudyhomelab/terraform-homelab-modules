# cloudyhome-image-index

Resolves one pinned image version from its published image index into download and storage settings. Read-only: it uses the `http` provider only and creates nothing.

Each image publishes `<index_base_url>/<os>/<type>/index.json` with a `BUILDS` list of image versions; each supplies its version as `BUILD_VERSION`, `IMAGE_URL`, `IMAGE_FILE`, `IMAGE_CHECKSUM` (`<algorithm>:<hex>`) and optionally `STORAGE`, the storage the image needs: a list of objects with required `app` and `dataset` and optional `recordsize`.

- The image version is pinned; nothing follows the newest one.
- The index is read at plan time. The plan fails when it is unreachable, lacks the pinned image version, has a `STORAGE` entry without `app` and `dataset`, or the pinned image version lacks `IMAGE_URL`, `IMAGE_FILE` or a well-formed `IMAGE_CHECKSUM`.

## Inputs

| Name             | Description | Required |
|------------------|-------------|----------|
| `index_base_url` | Base URL under which the indexes are published. | yes |
| `image`          | Image as `<os>/<type>`. | yes |
| `image_version`  | Pinned image version, as listed in the image's index. | yes |

## Outputs

| Name            | Description |
|-----------------|-------------|
| `image_version` | Pinned image version. |
| `download`      | `content_type` (`import`), `download_url`, `save_file_name`, `checksum_algorithm` and `checksum`. No target storage; the consumer adds it. |
| `storage`       | The image version's `STORAGE` as a list of `{app, dataset, recordsize}`, `recordsize` null when absent; empty when it declares none. |

## Usage

```hcl
module "runner_image" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-image-index?ref=main"

  index_base_url = "https://s3-api.cloudyhome.net/os-image-staging"
  image          = "debian/debian-runner"
  image_version  = "20261120T101500"
}

# module.runner_image.download
# module.runner_image.storage
```
