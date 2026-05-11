terraform {
  required_version = ">= 1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    popsrox = {
      source  = "POps-Rox/azutils"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id is provided by the consumer via ARM_SUBSCRIPTION_ID env var
}
