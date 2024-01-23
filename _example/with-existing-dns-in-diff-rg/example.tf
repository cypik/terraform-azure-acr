provider "azurerm" {
  features {}
}

locals {
  name        = "acr2"
  environment = "test"
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "cypik/resource-group/azure"
  version     = "1.0.1"
  name        = local.name
  environment = local.environment
  location    = "North Europe"
}

##-----------------------------------------------------------------------------
## Virtual Network module call.
## Virtual Network for which subnet will be created for private endpoint and vnet link will be created in private dns zone.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "cypik/vnet/azure"
  version             = "1.0.1"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

module "subnet" {
  source               = "cypik/subnet/azure"
  version              = "1.0.1"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]
}

## existing resource group name
data "azurerm_resource_group" "existing" {
  name = "acr1-test-resource-group"
}

## existing private dns zone
data "azurerm_private_dns_zone" "existing" {
  name                = "privatelink.azurecr.io"
  resource_group_name = data.azurerm_resource_group.existing.name
}


module "acr" {
  source              = "../../"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  container_registry_config = {
    name = "acrrr22" # Name of Container Registry
    sku  = "Premium"
  }

  virtual_network_id = module.vnet.id
  subnet_id          = [module.subnet.default_subnet_id]

  existing_private_dns_zone                     = data.azurerm_private_dns_zone.existing.name # Name of private dns zone remain same for acr.
  existing_private_dns_zone_id                  = data.azurerm_private_dns_zone.existing.id
  existing_private_dns_zone_resource_group_name = data.azurerm_resource_group.existing.name
}
