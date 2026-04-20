# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_redis_firewall_rule" "redis_fw_rule" {
  for_each = var.authorized_cidrs
  name     = var.use_naming ? data.popsrox_utils_resource_name.redis_fw_rule[each.key].result : each.key

  redis_cache_name    = azurerm_redis_cache.redis.name
  resource_group_name = local.resource_group_name

  start_ip = cidrhost(each.value, 0)
  end_ip   = cidrhost(each.value, -1)
}
