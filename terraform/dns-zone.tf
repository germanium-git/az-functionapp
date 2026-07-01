locals {
  dns_zones = {
    kv = {
      domain_name      = "privatelink.vaultcore.azure.net"
      vnetlinkname     = "vnetlink-kv"
      autoregistration = true
    }
    blob = {
      domain_name      = "privatelink.blob.core.windows.net"
      vnetlinkname     = "vnetlink-blob"
      autoregistration = false
    }
  }
}

# Terraform AVM module for Private DNS zones
# https://registry.terraform.io/modules/Azure/avm-res-network-privatednszone/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-network-privatednszone


module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.3"

  for_each = local.dns_zones

  enable_telemetry    = false
  domain_name         = each.value.domain_name
  resource_group_name = module.resource_group.monitoring.name

  # Optional: Virtual Network Link Configuration
  virtual_network_links = {
    monitoring = {
      vnetlinkname     = each.value.vnetlinkname
      vnetid           = module.virtual_network.monitoring.resource_id
      autoregistration = each.value.autoregistration
    }
  }

  tags = local.tags
}

# resource "azurerm_private_dns_a_record" "storage_blob_a_record" {
#   name                = module.storage_account["tfcustm"].resource.name
#   zone_name           = module.private_dns_zone["blob"].name
#   resource_group_name = module.resource_group.monitoring.name
#   ttl                 = 300
#   records             = [module.storage_account["tfcustm"].private_endpoints.private_ip_address]
# }
