provider "azurerm" {
  features {}
}

locals {
  name        = "acr1"
  environment = "test"
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "git::https://github.com/cypik/terraform-azure-resource-group.git?ref=v1.0.0"
  name        = local.name
  environment = local.environment
  location    = "North Europe"
}

##-----------------------------------------------------------------------------
## Virtual Network module call.
## Virtual Network for which subnet will be created for private endpoint and vnet link will be created in private dns zone.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "git::https://github.com/cypik/terraform-azure-vnet.git?ref=v1.0.0"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

##-----------------------------------------------------------------------------
## Subnet module call.
## Subnet in which private endpoint will be created.
##-----------------------------------------------------------------------------
module "subnet" {
  source = "git::https://github.com/cypik/terraform-azure-subnet.git?ref=v1.0.0"

  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name

  #subnet
  subnet_names    = ["default"]
  subnet_prefixes = ["10.0.1.0/24"]

}

##--------------------------------------------------------------------------
##-----------------------------------------------------------------------------
## ACR module call.
##-----------------------------------------------------------------------------
module "acr" {
  source              = "../../"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  container_registry_config = {
    name = "acrrr111" # Name of Container Registry
    sku  = "Premium"
  }
  ##-----------------------------------------------------------------------------
  ## To be mentioned for private endpoint, because private endpoint is enabled by default.
  ## To disable private endpoint set 'enable_private_endpoint' variable = false and than no need to specify following variable
  ##-----------------------------------------------------------------------------
  virtual_network_id = module.vnet.id
  subnet_id          = [module.subnet.default_subnet_id]
}
