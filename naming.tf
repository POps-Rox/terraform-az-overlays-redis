data "popsrox_utils_resource_name" "redis" {
  name          = var.workload_name
  resource_type = "azurerm_redis_cache"
  prefixes      = [var.org_name, module.mod_azure_region_lookup.location_short]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "redis"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "data_storage" {
  name          = "${var.workload_name}redis"
  resource_type = "azurerm_storage_account"
  prefixes      = [var.org_name, module.mod_azure_region_lookup.location_short]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "st"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "redis_fw_rule" {
  for_each = var.authorized_cidrs

  name          = var.workload_name
  resource_type = "azurerm_redis_firewall_rule"
  prefixes      = [var.org_name, module.mod_azure_region_lookup.location_short]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, each.key])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
