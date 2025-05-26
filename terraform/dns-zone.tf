# Terraform AVM module for Private DNS zones
# https://registry.terraform.io/modules/Azure/avm-res-network-privatednszone/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-network-privatednszone


module "private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.3"

  enable_telemetry    = false
  domain_name         = "monitoring.test.local"
  resource_group_name = module.resource_group.monitoring.name

  # Optional: Virtual Network Link Configuration
  virtual_network_links = {
    monitoring = {
      vnetlinkname     = "monitoring-link"
      vnetid           = module.virtual_network.monitoring.resource_id
      autoregistration = true
    }
  }

  tags = local.tags
}
