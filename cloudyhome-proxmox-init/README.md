# cloudyhome-proxmox-init

Proxmox user and API token for Terraform:

- a role with the privileges listed in `privileges.json`, or those given in `privileges`
- a user granted that role on `/`, propagated to every path below it
- an API token for the user without privilege separation, so it holds exactly the user's privileges

The user and the token expire together at `expiration_date`.

## Inputs

| Name              | Description | Required |
|-------------------|-------------|----------|
| `expiration_date` | RFC 3339 timestamp at which the user and the token expire, e.g. `2027-01-01T00:00:00Z`. | yes |
| `user_id`         | User to create, as `name@realm`. Default `terraform@pve`. | no |
| `token_name`      | Name of the API token. Default `terraform`. | no |
| `role_id`         | Name of the role granted to the user. Default `terraform-privileges`. | no |
| `privileges`      | Privileges of the role. Default `null` uses `privileges.json`. | no |
| `comment`         | Comment set on the user and the token. Default `to be used by terraform`. | no |

## Outputs

| Name         | Description |
|--------------|-------------|
| `user_token` | Full API token, as `user@realm!token=secret`, for the provider's `api_token` argument. Sensitive. |
| `token_id`   | Token ID, as `user@realm!token`. |
| `user_id`    | Created user. |
| `role_id`    | Created role. |

## Usage

The module bootstraps the credentials every other Proxmox module uses, so it runs in its own root module, authenticated as an administrator such as `root@pam`:

```hcl
provider "proxmox" {
  endpoint = "https://pve.example.lan:8006/"
  username = "root@pam"
  password = var.proxmox_root_password
}

module "proxmox_init" {
  source          = "git::https://github.com/cloudyhomelab/terraform-homelab-modules.git//cloudyhome-proxmox-init?ref=main"
  expiration_date = "2027-01-01T00:00:00Z"
}

output "proxmox_api_token" {
  value     = module.proxmox_init.user_token
  sensitive = true
}
```

Read the token with `terraform output -raw proxmox_api_token` and pass it as `api_token` to the provider of the other root modules. The token secret is stored in the Terraform state, so keep the state private.

To rotate the token, run `terraform apply -replace=module.proxmox_init.proxmox_user_token.this`; the new secret appears in the output.
