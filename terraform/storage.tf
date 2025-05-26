module "storage_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  for_each      = local.storageaccounts
  suffix        = [local.uniquekey]
  unique-length = 4
}


# Specify your storage accounts here
locals {
  storageaccounts = {
    tfavm = {
      location                      = module.resource_group.monitoring.resource.location
      resource_group_name           = module.resource_group.monitoring.name
      public_network_access_enabled = true
      network_rules = {
        bypass = ["AzureServices"]
        # default_action = "Deny"
        default_action = "Allow" # This allows access from all networks
        # ip_rules       = ["185.230.172.74", "193.179.215.98"]
        #   virtual_network_subnet_ids = [
        #     module.virtual_network.monitoring.subnets.subnet1.resource_id,
        #     module.virtual_network.monitoring.subnets.subnet0_funcapp.resource_id
        #   ]
      }
      containers = {
        monitoring = {
          # https://github.com/hashicorp/terraform-provider-azurerm/issues/2977#issuecomment-2380297240
          # container_access_type = "private"
          name = "monitoring"
          role_assignments = {
            contributor = {
              role_definition_id_or_name = "Storage Blob Data Contributor"
              principal_id               = data.azurerm_client_config.current.object_id
            }
          }
        }
      }
      # private_endpoints = {
      #   blob = {
      #     name                          = "${local.uniquekey}monitoring-endpoint"
      #     subresource_name              = "blob"
      #     subnet_resource_id            = module.virtual_network.monitoring.subnets.subnet1.resource_id
      #     private_dns_zone_resource_ids = [module.private_dns_zone.resource_id]
      #   }
      # }
    }
    tfcustm = {
      location                      = module.resource_group.monitoring.resource.location
      resource_group_name           = module.resource_group.monitoring.name
      public_network_access_enabled = true
      network_rules = {
        bypass         = ["AzureServices"]
        default_action = "Allow" # This allows access from all networks
      }
      containers = {
        monitoring = {
          name = "monitoring"
          role_assignments = {
            contributor = {
              role_definition_id_or_name = "Storage Blob Data Contributor"
              principal_id               = data.azurerm_client_config.current.object_id
            }
          }
        }
      }
    }
    tfazapi = {
      location                      = module.resource_group.monitoring.resource.location
      resource_group_name           = module.resource_group.monitoring.name
      public_network_access_enabled = true
      network_rules = {
        bypass         = ["AzureServices"]
        default_action = "Allow" # This allows access from all networks
      }
      containers = {
        monitoring = {
          name = "monitoring"
          role_assignments = {
            contributor = {
              role_definition_id_or_name = "Storage Blob Data Contributor"
              principal_id               = data.azurerm_client_config.current.object_id
            }
          }
        }
      }
    }
    bicep = {
      location                      = module.resource_group.monitoring.resource.location
      resource_group_name           = module.resource_group.monitoring.name
      public_network_access_enabled = true
      network_rules = {
        bypass         = ["AzureServices"]
        default_action = "Allow" # This allows access from all networks
      }
      containers = {
        monitoring = {
          name = "monitoring"
          role_assignments = {
            contributor = {
              role_definition_id_or_name = "Storage Blob Data Contributor"
              principal_id               = data.azurerm_client_config.current.object_id
            }
          }
        }
      }
    }
    portal = {
      location                      = module.resource_group.monitoring.resource.location
      resource_group_name           = module.resource_group.monitoring.name
      public_network_access_enabled = true
      network_rules = {
        bypass         = ["AzureServices"]
        default_action = "Allow" # This allows access from all networks
      }
      containers = {
        monitoring = {
          name = "monitoring"
          role_assignments = {
            contributor = {
              role_definition_id_or_name = "Storage Blob Data Contributor"
              principal_id               = data.azurerm_client_config.current.object_id
            }
          }
        }
      }
    }
  }
}


# Terraform module is designed to create Azure Storage Accounts
# https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount


module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.1"

  for_each = local.storageaccounts

  enable_telemetry = false

  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  name                = module.storage_naming[each.key].storage_account.name_unique

  account_replication_type = "LRS"

  # Workaround to solve the issue causing the procedure of creating containers to faiil
  shared_access_key_enabled = true

  public_network_access_enabled = each.value.public_network_access_enabled
  network_rules                 = try(each.value.network_rules, null)
  containers                    = try(each.value.containers, null)

  tags = {
    owner = local.uniquekey
  }
}
