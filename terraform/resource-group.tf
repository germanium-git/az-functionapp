# This ensures we have unique CAF compliant names for our resources.
module "rg_naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.2"

  suffix        = [local.uniquekey]
  unique-length = 4
}

# Specify your resource groups here
locals {
  resource_groups = {
    monitoring = {
      location = var.location
    }
  }
  tags = {
    owner = local.uniquekey
  }
}

# Module to deploy resource groups in Azure
# https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/latest
# https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup


module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  for_each = local.resource_groups


  name             = "${module.rg_naming.resource_group.name_unique}-${each.key}"
  location         = each.value.location
  tags             = local.tags
  enable_telemetry = false
}
