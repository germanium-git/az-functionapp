module "funapp_tf_custm" {
  source = "./modules/funcapp"

  resource_group_name = module.resource_group.monitoring.name
  location            = module.resource_group.monitoring.resource.location

  tags = merge(local.tags, { code = "terraform-custm" })

  distinguisher = local.uniquekey


  storage_account_name       = module.storage_account.tfcustm.resource.name
  storage_container_type     = "blobContainer"
  storage_container_endpoint = "${module.storage_account["tfcustm"].resource.primary_blob_endpoint}monitoring"
}
