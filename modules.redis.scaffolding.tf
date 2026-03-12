# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Azure Region Lookup
#----------------------------------------------------------
module "mod_azure_region_lookup" {
  source = "github.com/POps-Rox/tf-az-overlays-azregionslookup"

  azure_region = var.location
}

#---------------------------------------------------------
# Resource Group Creation
#----------------------------------------------------------
data "azurerm_resource_group" "rgrp" {
  count = var.create_redis_resource_group == false ? 1 : 0
  name  = var.existing_resource_group_name
}

module "mod_redis_rg" {
  source = "github.com/POps-Rox/tf-az-overlays-resourcegroup"

  count = var.create_redis_resource_group ? 1 : 0

  location                = module.mod_azure_region_lookup.location_cli
  use_location_short_name = var.use_location_short_name # Use the short location name in the resource group name
  org_name                = var.org_name
  environment             = var.deploy_environment
  workload_name           = var.workload_name
  custom_rg_name          = var.custom_resource_group_name != null ? var.custom_resource_group_name : null

  // Tags
  add_tags = merge(local.default_tags, var.add_tags) # Tags to be applied to all resources
}
