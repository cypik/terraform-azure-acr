provider "azurerm" {
  features {}
}

locals {
  name        = "badh"
  environment = "test"
}

##----------------------------------------------------------------------------- 
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "git::git@github.com:opz0/terraform-azure-resource-group.git?ref=master"
  name        = "appvm-linux"
  environment = "tested"
  location    = "North Europe"
}

##----------------------------------------------------------------------------- 
## Virtual Network module call.
## Virtual Network for which subnet will be created for private endpoint and vnet link will be created in private dns zone.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "git::git@github.com:opz0/terraform-azure-vnet.git?ref=master"
  name                = "badh"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}

module "subnet" {
  source = "git::git@github.com:opz0/terraform-azure-subnet.git?ref=master"

  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name[0]

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]

  # route_table
  enable_route_table = true
  route_table_name   = "default_subnet"
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}


module "container-registry" {
  source              = "../../"
  name                = local.name # Name used for specifying tags and other resources naming.(like private endpoint, vnet-link etc)
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  container_registry_config = {
    name = "cdacr1" # Name of Container Registry
    sku  = "Premium"
  }

  log_analytics_workspace_id = ""

  virtual_network_id = join("", module.vnet.vnet_id)
  subnet_id          = [module.subnet.default_subnet_id]


  existing_private_dns_zone_id                  = ["privatelink.azurecr.io"] # Name of private dns zone remain same for acr.
  existing_private_dns_zone_resource_group_name = "complete-tested-resource-group"
}
