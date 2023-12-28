# terraform-azure-acr
# Terraform Infrastructure as Code (IaC) - Azure Container Registry(ACR) Module

## Table of Contents
- [Introduction](#Introduction)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Authors](#authors)
- [License](#license)

## Introduction
This Terraform module creates an Azure Container Registry(ACR) along with additional configuration options.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) installed
- Azure subscription and credentials set up

## Usage



1. Use the module by referencing its source and providing the required variables.
# Examples:

# Example: default
```hcl
    module "acr" {
      source              = "git::https://github.com/cypik/terraform-azure-acr.git?ref=v1.0.0"
      name                = local.name
      environment         = local.environment
      resource_group_name = module.resource_group.resource_group_name
      location            = module.resource_group.resource_group_location
      container_registry_config = {
      name = "acrrr111" # Name of Container Registry
      sku  = "Premium"
        }
      virtual_network_id = module.vnet.id
      subnet_id          = [module.subnet.default_subnet_id]
      }
   ```
# Example: with-existing-dns-in-diff-rg

```hcl
    module "acr" {
      source              = "git::https://github.com/cypik/terraform-azure-acr.git?ref=v1.0.0"
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
   ```

# Example: with-existing-dns-in-diff-subs

```hcl
    module "acr" {
      source              = "git::https://github.com/cypik/terraform-azure-acr.git?ref=v1.0.0"
      name                = local.name 
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
      alias_sub                                     = "082xxxxxxxxxxxxabc60c"  # Subcription id in which dns zone is present.
      existing_private_dns_zone                     = "privatelink.azurecr.io" # Name of private dns zone remain same for acr.
      existing_private_dns_zone_id                  = "/subscriptions/08xxxxxxxxxxxxxxx9c0c/resourceGroups/app-test-resource-group/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
      existing_private_dns_zone_resource_group_name = "app-test-resource-group"
      }
   ```
    

2. Run `terraform init` and `terraform apply` to create the Azure Resource Group.

## Module Inputs

- `name`: The name of the resource group.
- `environment`: The environment (e.g., "test", "production").

## Module Outputs

This module provides the following outputs:

- `acr_id` : The ID of the Container Registry
- `acr_private_dns_zone`: DNS zone name of Azure Container Registry Private endpoints dns name records
## Authors
- This module was created by [Your Name] and can be found in [Your GitHub Repository URL].

If you have any questions, issues, or suggestions related to this module, please feel free to open an issue on the repository.

Happy Terraforming!

## License
- This project is licensed under the MIT License - see the [LICENSE](https://github.com/cypik/terraform-azure-acr/blob/master/LICENSE) file for details.



