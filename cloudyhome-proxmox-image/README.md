# cloudyhome-proxmox-image

Downloads a file from a URL onto a Proxmox storage of every node in the cluster: an ISO, a disk image or a container template.

## Inputs

| Name     | Description | Required |
|----------|-------------|----------|
| `config` | Download settings, see below. | yes |

`config` attributes:

| Name                      | Description | Default |
|---------------------------|-------------|---------|
| `datastore_id`            | Storage the file is saved on; it must allow `content_type`. | `local` |
| `download_url`            | URL to download from. | required |
| `content_type`            | `iso`, `import` or `vztmpl`. | `iso` |
| `save_file_name`          | File name on the storage; `null` takes it from the URL. | `null` |
| `checksum`                | Expected checksum of the downloaded file. | required |
| `checksum_algorithm`      | Algorithm of `checksum`, e.g. `sha256`. | required |
| `decompression_algorithm` | Decompress after download: `gz`, `lzo`, `zst` or `bz2`. An `.xz` download needs `zst`, whose decompressor also reads xz. | `null` |
| `overwrite`               | Download again when the stored file's size changes outside Terraform or differs from the URL's. | `true` |

Proxmox accepts only `*.iso` and `*.img` names for content type `iso`, so a disk image such as a `.qcow2` is saved under a `.img` name there, or as content type `import` under its own name.

## Outputs

| Name           | Description |
|----------------|-------------|
| `file_ids`     | File IDs keyed by node, for a VM disk or CD-ROM `file_id`. |
| `file_name`    | File name on the storage. |
| `content_type` | Content type the file is stored as. |
| `datastore_id` | Storage the file is saved on. |

## Usage

```hcl
module "debian_image" {
  source = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-proxmox-image?ref=main"

  config = {
    content_type       = "import"
    download_url       = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
    checksum           = "<sha512 from SHA512SUMS>"
    checksum_algorithm = "sha512"
  }
}
```
