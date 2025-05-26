output "rg_names" {
  value = { for k, v in module.resource_group : k => v.resource.name }
}

output "vnet_names" {
  value = { for k, v in module.virtual_network : k => v.resource.name }
}

output "kv_name" {
  value = module.key_vault.name
}

output "kv_id" {
  value = module.key_vault.resource_id
}

output "storage_account_names" {
  value = { for k, v in module.storage_account : k => v.resource.name }
}

output "storage_account_ids" {
  value = { for k, v in module.storage_account : k => v.resource.id }
}

output "storage_account_fqdn" {
  value = { for k, v in module.storage_account : k => v.fqdn }
}

output "storage_account_containers" {
  value = { for k, v in module.storage_account : k => v.containers }
}


output "funcapp_tfavm_principal_id" {
  value = module.function_app.system_assigned_mi_principal_id
}

output "funcapp_tfcustm_principal_id" {
  value = module.funapp_tf_custm.function_app_principal_id
}

output "function_azapi_principal_id" {
  value = azapi_resource.functionApps.output.identity.principalId
}
