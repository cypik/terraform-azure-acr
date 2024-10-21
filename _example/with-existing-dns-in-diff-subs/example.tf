provider "azurerm" {
  features {}
}

locals {
  name        = "app"
  environment = "test"
}

module "resource_group" {
  source      = "cypik/resource-group/azure"
  version     = "1.0.2"
  name        = local.name
  environment = local.environment
  location    = "North Europe"
}


module "vnet" {
  source              = "cypik/vnet/azure"
  version             = "1.0.2"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.30.0.0/16"
}


module "subnet" {
  source               = "cypik/subnet/azure"
  version              = "1.0.2"
  name                 = local.name
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.30.1.0/24"]

}

###-----------------------------------------------------------------------------
## ACR module call.
##-----------------------------------------------------------------------------
module "acr" {
  source              = "../../"
  name                = local.name # Name used for specifying tags and other resources naming.(like private endpoint, vnet-link etc)
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  container_registry_config = {
    name = "diffacr1234" # Name of Container Registry
    sku  = "Premium"
  }

  virtual_network_id = module.vnet.id
  subnet_id          = [module.subnet.default_subnet_id]


  diff_sub                                      = true
  alias_sub                                     = "xxxxxxxxxxxxxxxxxxxx"   # Subcription id in which dns zone is present.
  existing_private_dns_zone                     = "privatelink.azurecr.io" # Name of private dns zone remain same for acr.
  existing_private_dns_zone_id                  = "/subscriptions/08xxxxxxxxxxxxxxx9c0c/resourceGroups/app-test-resource-group/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
  existing_private_dns_zone_resource_group_name = "app-test-resource-group"
}
