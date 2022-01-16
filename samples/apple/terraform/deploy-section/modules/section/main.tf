locals {
  function_app_name = "func-${var.resource_identifier}"
}

resource "azurerm_resource_group" "section" {
  name     = "rg-${var.resource_identifier}"
  location = var.location
}
