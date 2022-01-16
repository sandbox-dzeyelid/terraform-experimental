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

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "shared" {
  name     = var.shared_resource_group_name
  location = var.location
}

resource "azurerm_mssql_server" "shared" {
  name                         = var.shared_mssql_server_name
  location                     = azurerm_resource_group.shared.location
  resource_group_name          = azurerm_resource_group.shared.name
  version                      = "12.0"
  administrator_login          = var.shared_mssql_server_administrator_login_name
  administrator_login_password = var.shared_mssql_server_administrator_login_password

  # azuread_administrator {

  # }
}

resource "azurerm_mssql_firewall_rule" "shared" {
  name             = "FIrewallRule1"
  server_id        = azurerm_mssql_server.shared.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
