terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.90.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

locals {
  divisions = {
    apple = {
      identifier = "playground20220103-apple"
    }
  }
}

module "division" {
  source = "./modules/division"

  for_each = local.divisions

  identifier = each.value.identifier
}
