# This ensures we have unique CAF compliant names for our resources.
module "func_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  suffix        = [local.uniquekey]
  unique-length = 4
}

resource "azurerm_service_plan" "monitoring" {
  resource_group_name = module.resource_group.monitoring.name
  location            = module.resource_group.monitoring.resource.location
  name                = module.func_naming.app_service_plan.name_unique

  os_type  = "Linux"
  sku_name = "FC1"

  tags = local.tags
}


# The module to create managed identity
# https://registry.terraform.io/modules/Azure/avm-res-managedidentity-userassignedidentity/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-managedidentity-userassignedidentity

module "userassignedidentity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.3.4"

  enable_telemetry = false

  resource_group_name = module.resource_group.monitoring.name
  location            = module.resource_group.monitoring.resource.location
  name                = module.func_naming.user_assigned_identity.name_unique
}


# The module to deploy function apps in Azure.
# https://registry.terraform.io/modules/Azure/avm-res-web-site/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-web-site

# !!! DOES NOT WORK WITH USer Assignd Identity - bug in module

module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.16.4"

  enable_telemetry = false

  name                = "${module.func_naming.function_app.name_unique}-avm"
  resource_group_name = module.resource_group.monitoring.name
  location            = module.resource_group.monitoring.resource.location

  kind = "functionapp"

  # Flex Consumption Plan
  function_app_uses_fc1 = true
  fc1_runtime_name      = "python"
  fc1_runtime_version   = "3.11"

  app_settings = {
    AzureWebJobsStorage__blobServiceUri  = "https://${module.storage_account["tfavm"].resource.name}.blob.core.windows.net"
    AzureWebJobsStorage__queueServiceUri = "https://${module.storage_account["tfavm"].resource.name}.queue.core.windows.net"
    AzureWebJobsStorage__tableServiceUri = "https://${module.storage_account["tfavm"].resource.name}.table.core.windows.net"
    # AzureWebJobsStorage__clientId        = module.userassignedidentity.client_id
    AzureWebJobsStorage__credential = "managedidentity"
  }

  # managed_identities = {
  #   user_assigned_resource_ids = [module.userassignedidentity.resource_id]
  # }

  managed_identities = {
    system_assigned = true
  }

  https_only = false

  public_network_access_enabled = true

  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.monitoring.os_type
  service_plan_resource_id = azurerm_service_plan.monitoring.id

  # Uses an existing storage account
  storage_account_name = module.storage_account["tfavm"].name
  # storage_account_access_key  = module.storage_account.resource.primary_access_key
  # storage_authentication_type = "StorageAccountConnectionString"
  storage_authentication_type = "SystemAssignedIdentity"
  # storage_authentication_type   = "UserAssignedIdentity"
  storage_uses_managed_identity = true
  storage_container_endpoint    = "${module.storage_account["tfavm"].resource.primary_blob_endpoint}monitoring"
  storage_container_type        = "blobContainer"
  # storage_key_vault_secret_id = ""

  enable_application_insights = false

  #   application_insights = {
  #     workspace_resource_id = azurerm_log_analytics_workspace.example_production.id
  #   }

  # virtual_network_subnet_id = module.virtual_network.monitoring.subnets.subnet0_funcapp.resource_id

  # private_endpoints = {
  #   funcapp = {
  #     name                          = "${local.uniquekey}funcapp-endpoint"
  #     subnet_resource_id            = module.virtual_network.monitoring.subnets.subnet1.resource_id
  #     private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
  #   }
  # }

  tags = merge(local.tags, { code = "terraform-avm" })

}


# # Check this out - https://github.com/hashicorp/terraform-provider-azurerm/issues/17930
# resource "azurerm_app_service_virtual_network_swift_connection" "example" {
#   app_service_id = module.function_app.resource_id
#   subnet_id      = module.virtual_network.monitoring.subnets.subnet0_funcapp.resource_id
# }
