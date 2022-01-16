resource "random_string" "storage_for_func" {
  length  = 22
  upper   = false
  special = false
  keepers = {
    resource_group_id = azurerm_resource_group.section.id
    function_app_name = local.function_app_name
  }
}

// Storage account for func
resource "azurerm_storage_account" "func" {
  name                     = "st${random_string.storage_for_func.result}"
  location                 = azurerm_resource_group.section.location
  resource_group_name      = azurerm_resource_group.section.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// Azure Service plan
resource "azurerm_app_service_plan" "section" {
  name                = "plan-${var.resource_identifier}"
  location            = azurerm_resource_group.section.location
  resource_group_name = azurerm_resource_group.section.name
  kind                = "functionapp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

}

// Azure functions (linux)
resource "azurerm_function_app" "section" {
  name                       = local.function_app_name
  location                   = azurerm_resource_group.section.location
  resource_group_name        = azurerm_resource_group.section.name
  app_service_plan_id        = azurerm_app_service_plan.section.id
  storage_account_name       = azurerm_storage_account.func.name
  storage_account_access_key = azurerm_storage_account.func.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    SAMPLE_ENVIRONMENT_VARIABLE = "sample environment variable"
  }
}
