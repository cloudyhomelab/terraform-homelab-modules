output "shares" {
  description = "<app>/<dataset> => dataset name, share path and allowed hosts, for datasets with at least one addressed client."
  value = {
    for pair in keys(local.shared) : pair => {
      dataset = truenas_dataset.data[pair].name
      path    = truenas_nfs_share.data[pair].path
      hosts   = truenas_nfs_share.data[pair].hosts
    }
  }
}
