# This ensures we have unique CAF compliant names for our resources.
module "vnet_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  suffix        = [local.uniquekey]
  unique-length = 4
}

locals {
  vnets = {
    monitoring = {
      address_space = ["10.0.0.0/16"]
      subnets = {
        subnet0 = {
          address_prefix = "10.0.0.0/24"
          delegation = [
            {
              name = "functionapp-delegation"
              service_delegation = {
                # Elastic Premium and Dedicated (App Service) plans
                # name = "Microsoft.Web/serverFarms"
                # Flex Consumption plan
                # https://learn.microsoft.com/en-us/azure/azure-functions/functions-networking-options?tabs=azure-portal#regional-virtual-network-integration
                name = "Microsoft.App/environments"
                actions = [
                  "Microsoft.Network/virtualNetworks/subnets/action"
                ]
                service_endpoints = ["Microsoft.Storage"]
              }
            }
          ]
        }
        subnet1 = {
          address_prefix    = "10.0.1.0/24"
          service_endpoints = ["Microsoft.Storage"]
        }
      }
      # foo = {
      #   address_space = ["10.1.0.0/16"]
      #   subnets = {
      #     subnet0 = "10.1.0.0/24"
      #     subnet1 = "10.1.1.0/24"
      #     subnet2 = "10.1.2.0/24"
      #   }
      # }
      # bar = {
      #   address_space = ["10.2.0.0/16"]
      #   subnets = {
      #     subnet0 = "10.2.0.0/24"
      #     subnet1 = "10.2.1.0/24"
      #   }
      # }
    }
  }
}


# Azure Verified Module for Virtual Network
# https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork


module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  for_each = local.vnets

  enable_telemetry = false

  name                = "${module.vnet_naming.virtual_network.name_unique}-${each.key}"
  resource_group_name = module.resource_group.monitoring.name
  location            = module.resource_group.monitoring.resource.location
  address_space       = each.value.address_space


  subnets = { for subnet_key, subnet_value in each.value.subnets : subnet_key => merge({ name = subnet_key }, subnet_value) }

  tags = local.tags
}

