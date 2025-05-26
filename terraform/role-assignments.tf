locals {
  role_assignments = {
    funcapp-tfavm-blob-access = {
      principal_id         = module.userassignedidentity.principal_id
      role_definition_name = "Storage Blob Data Owner"
      scope                = module.storage_account.tfavm.resource.id
    }
    funcapp-tfavm-subscription-reader = {
      principal_id         = module.userassignedidentity.principal_id
      role_definition_name = "Reader"
      scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
    }
    funcapp-tfavm-kv-access = {
      principal_id         = module.userassignedidentity.principal_id
      role_definition_name = "Key Vault Secrets User"
      scope                = module.key_vault.resource_id
    }
    funcapp-tfcustm-blob-access = {
      principal_id         = module.funapp_tf_custm.function_app_principal_id
      role_definition_name = "Storage Blob Data Owner"
      scope                = module.storage_account.tfcustm.resource.id
    }
    funcapp-tfcustm-subscription-reader = {
      principal_id         = module.funapp_tf_custm.function_app_principal_id
      role_definition_name = "Reader"
      scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
    }
    funcapp-tfcustm-kv-access = {
      principal_id         = module.funapp_tf_custm.function_app_principal_id
      role_definition_name = "Key Vault Secrets User"
      scope                = module.key_vault.resource_id
    }
    funcapp-tfazapi-blob-access = {
      principal_id         = azapi_resource.functionApps.output.identity.principalId
      role_definition_name = "Storage Blob Data Owner"
      scope                = module.storage_account.tfazapi.resource.id
    }
    funcapp-tfazapi-subscription-reader = {
      principal_id         = azapi_resource.functionApps.output.identity.principalId
      role_definition_name = "Reader"
      scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
    }
    funcapp-tfazapi-kv-access = {
      principal_id         = azapi_resource.functionApps.output.identity.principalId
      role_definition_name = "Key Vault Secrets User"
      scope                = module.key_vault.resource_id
    }
  }
}



# AVM Terraform module for role assignments
# https://registry.terraform.io/modules/Azure/avm-res-authorization-roleassignment/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-authorization-roleassignment

module "role_assignments" {
  source  = "Azure/avm-res-authorization-roleassignment/azurerm"
  version = "0.2.0"

  enable_telemetry = false

  role_assignments_azure_resource_manager = local.role_assignments
}
