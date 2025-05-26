# This ensures we have unique CAF compliant names for our resources.
module "kv_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  suffix        = [local.uniquekey]
  unique-length = 4
  # KV name must be between 3 and 24 characters long and can only contain letters, numbers and dashes.
}

# Azure Verified Module for Key Vault
# https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault


module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  enable_telemetry = false

  resource_group_name = module.resource_group.monitoring.name
  location            = module.resource_group.monitoring.resource.location
  name                = module.rg_naming.key_vault.name_unique
  tenant_id           = data.azurerm_client_config.current.tenant_id

  public_network_access_enabled = true

  network_acls = {
    bypass = "AzureServices"
    # default_action = "Deny"
    default_action = "Allow" # This allows access from all networks
    # ip_rules       = ["185.230.172.74", "193.179.215.98"]
    # virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }

  # # Private Endpoint Configuration
  # private_endpoints = {
  #   primary = {
  #     private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
  #     subnet_resource_id            = module.virtual_network.monitoring.subnets.subnet1.resource_id
  #   }
  # }

  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
  secrets = {
    secret1 = {
      name = "secret1"
    }
  }
  secrets_value = {
    secret1 = "secret1-value"
  }

  tags = local.tags
}
