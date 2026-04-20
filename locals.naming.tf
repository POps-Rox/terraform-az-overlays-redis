locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_redis_rg.*.resource_group_name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_redis_rg.*.resource_group_location, [""]), 0)
  redis_name          = coalesce(var.custom_name, data.popsrox_resource_name.redis.result)
  storage_name        = coalesce(var.data_persistence_storage_custom_name, data.popsrox_resource_name.data_storage.result)
}
