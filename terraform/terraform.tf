terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.10.0"
    }
  }
  required_version = "1.11.4"
}


provider "azurerm" {
  features {}
}

provider "azapi" {}
