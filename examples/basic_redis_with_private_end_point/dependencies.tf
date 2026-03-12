
#---------------------------------------------------------
# Azure Region Lookup
#----------------------------------------------------------
module "mod_azure_region_lookup" {
  source = "github.com/POps-Rox/tf-az-overlays-azregionslookup"

  azure_region = "eastus"
}

resource "azurerm_resource_group" "redis_rg" {
  name     = "rg-redis"
  location = module.mod_azure_region_lookup.location_cli
}

resource "azurerm_virtual_network" "redis_vnet" {
  name                = "vnet-redis"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.redis_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "redis_subnet" {
  name                 = "snet-redis"
  resource_group_name  = azurerm_resource_group.redis_rg.name
  virtual_network_name = azurerm_virtual_network.redis_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "redis_pe_subnet" {
  name                 = "snet-pe-redis"
  resource_group_name  = azurerm_resource_group.redis_rg.name
  virtual_network_name = azurerm_virtual_network.redis_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}
