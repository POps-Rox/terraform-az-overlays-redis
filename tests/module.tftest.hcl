mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      name     = "rg-existing"
      location = "eastus"
    }
  }

  mock_data "azurerm_virtual_network" {
    defaults = {
      name = "vnet-redis"
      id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-redis"
    }
  }

  mock_data "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-redis/subnets/snet-redis"
    }
  }

  mock_data "azurerm_private_endpoint_connection" {
    defaults = {
      private_service_connection = [{
        private_ip_address = "10.0.3.4"
      }]
    }
  }

  mock_resource "azurerm_storage_account" {
    defaults = {
      id                             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-created/providers/Microsoft.Storage/storageAccounts/mockredis"
      primary_blob_connection_string = "DefaultEndpointsProtocol=https;AccountName=mockredis;AccountKey=mock;EndpointSuffix=core.windows.net"
    }
  }

  mock_resource "azurerm_redis_cache" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-created/providers/Microsoft.Cache/Redis/redis-private"
    }
  }

  mock_resource "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-created/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"
    }
  }
}

mock_provider "azapi" {}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "mockredis"
    }
  }
}

override_module {
  target = module.mod_azure_region_lookup
  outputs = {
    location_cli   = "eastus"
    location_short = "eus"
  }
}

override_module {
  target = module.mod_redis_rg
  outputs = {
    resource_group_name     = "rg-created"
    resource_group_location = "eastus"
  }
}

run "custom_name_tags_and_disabled_conditionals" {
  command = plan

  variables {
    location                    = "eastus"
    create_redis_resource_group = true
    custom_name                 = "redis-custom"
    data_persistence_enabled    = false
    sku_name                    = "Basic"
    capacity                    = 1
    deploy_environment          = "qa"
    workload_name               = "cache"
    add_tags = {
      env   = "override"
      Owner = "platform"
    }
  }

  assert {
    condition     = azurerm_redis_cache.redis.name == "redis-custom"
    error_message = "custom_name must override the generated Redis name."
  }

  assert {
    condition     = azurerm_redis_cache.redis.location == "eastus"
    error_message = "Redis location must pass through the resolved module location."
  }

  assert {
    condition     = azurerm_redis_cache.redis.tags["env"] == "override" && azurerm_redis_cache.redis.tags["workload"] == "cache" && azurerm_redis_cache.redis.tags["Owner"] == "platform"
    error_message = "Redis tags must merge default tags with add_tags, allowing add_tags to override defaults."
  }

  assert {
    condition     = length(azurerm_private_endpoint.pep) == 0 && length(azurerm_private_dns_zone.dns_zone) == 0 && length(azurerm_private_dns_zone_virtual_network_link.vnet_link) == 0 && length(azurerm_private_dns_a_record.a_rec) == 0
    error_message = "Private endpoint resources must not be planned when enable_private_endpoint is false."
  }

  assert {
    condition     = length(azurerm_management_lock.redis_level_lock) == 0 && length(azurerm_management_lock.storage_account_level_lock) == 0
    error_message = "Management locks must not be planned when enable_resource_locks is false."
  }
}

run "empty_string_names_fall_through" {
  command = plan

  variables {
    location                    = "eastus"
    create_redis_resource_group = true
    custom_name                 = ""
    data_persistence_enabled    = false
    sku_name                    = "Basic"
    capacity                    = 1
  }

  assert {
    condition     = azurerm_redis_cache.redis.name == "mockredis"
    error_message = "An empty custom_name must fall through to the generated Redis name."
  }
}

run "enabled_conditionals_and_private_dns_ids" {
  command = apply

  variables {
    location                     = "eastus"
    create_redis_resource_group  = true
    custom_name                  = "redis-private"
    data_persistence_enabled     = true
    sku_name                     = "Premium"
    capacity                     = 1
    enable_private_endpoint      = true
    existing_private_subnet_name = "snet-pe-redis"
    virtual_network_name         = "vnet-redis"
    enable_resource_locks        = true
  }

  assert {
    condition     = length(azurerm_private_endpoint.pep) == 1 && length(azurerm_private_dns_zone.dns_zone) == 1 && length(azurerm_private_dns_zone_virtual_network_link.vnet_link) == 1 && length(azurerm_private_dns_a_record.a_rec) == 1
    error_message = "Private endpoint resources must be planned when enable_private_endpoint is true with subnet inputs."
  }

  assert {
    condition     = azurerm_private_dns_zone_virtual_network_link.vnet_link[0].private_dns_zone_id == azurerm_private_dns_zone.dns_zone[0].id && azurerm_private_dns_a_record.a_rec[0].private_dns_zone_id == azurerm_private_dns_zone.dns_zone[0].id
    error_message = "Private DNS link and A record must use the private DNS zone ID."
  }

  assert {
    condition     = length(azurerm_storage_account.redis_storage) == 1 && length(azurerm_management_lock.redis_level_lock) == 1 && length(azurerm_management_lock.storage_account_level_lock) == 1
    error_message = "Data persistence storage and management locks must be planned when enabled."
  }
}
