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
  sections = {
    for section in var.sections : section.name => section
  }
}

module "section" {
  source = "./modules/section"

  for_each = local.sections

  resource_identifier                             = each.value.resource_identifier
  shared_resource_group_name                      = var.shared_resource_group_name
  shared_mssql_server_name                        = var.shared_mssql_server_name
  shared_mssql_server_administrator_login_password = var.shared_mssql_server_administrator_login_password
}
