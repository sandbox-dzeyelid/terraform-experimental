locals {
  function_app_name = "func-${var.identifier}"
}

resource "azurerm_resource_group" "division" {
  name     = "rg-${var.identifier}"
  location = var.location
}

// Random storing for storage account name
resource "random_string" "storage_for_division" {
  length  = 22
  upper   = false
  special = false
  keepers = {
    resource_group_id = azurerm_resource_group.division.id
  }
}

resource "random_string" "storage_for_func" {
  length  = 22
  upper   = false
  special = false
  keepers = {
    resource_group_id = azurerm_resource_group.division.id
    function_app_name = local.function_app_name
  }
}

// Storage account
resource "azurerm_storage_account" "division" {
  name                     = "st${random_string.storage_for_division.result}"
  location                 = azurerm_resource_group.division.location
  resource_group_name      = azurerm_resource_group.division.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

// Storage account for func
resource "azurerm_storage_account" "func" {
  name                     = "st${random_string.storage_for_func.result}"
  location                 = azurerm_resource_group.division.location
  resource_group_name      = azurerm_resource_group.division.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "func" {
  name                = "appi-${local.function_app_name}"
  location            = azurerm_resource_group.division.location
  resource_group_name = azurerm_resource_group.division.name
  application_type    = "other"

}

// Azure Service plan
resource "azurerm_app_service_plan" "division" {
  name                = "plan-${var.identifier}"
  location            = azurerm_resource_group.division.location
  resource_group_name = azurerm_resource_group.division.name
  kind                = "functionapp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

// Azure functions (linux)
resource "azurerm_function_app" "division" {
  name                       = local.function_app_name
  location                   = azurerm_resource_group.division.location
  resource_group_name        = azurerm_resource_group.division.name
  app_service_plan_id        = azurerm_app_service_plan.division.id
  storage_account_name       = azurerm_storage_account.func.name
  storage_account_access_key = azurerm_storage_account.func.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.func.instrumentation_key
  }
}

data "azurerm_function_app_host_keys" "division" {
  name                = local.function_app_name
  resource_group_name = azurerm_resource_group.division.name

  depends_on = [
    azurerm_function_app.division,
  ]
}

// SQL Database

// Data factory
resource "azurerm_data_factory" "division" {
  name                = "adf-${var.identifier}"
  location            = azurerm_resource_group.division.location
  resource_group_name = azurerm_resource_group.division.name
}

resource "azurerm_data_factory_linked_service_azure_function" "division" {
  name                = "AzureFunction1"
  resource_group_name = azurerm_resource_group.division.name
  data_factory_id     = azurerm_data_factory.division.id
  url                 = "https://${azurerm_function_app.division.default_hostname}"
  key                 = data.azurerm_function_app_host_keys.division.default_function_key
}

resource "azurerm_data_factory_trigger_schedule" "division" {
  name                = "trigger1"
  resource_group_name = azurerm_resource_group.division.name
  data_factory_id     = azurerm_data_factory.division.id
  pipeline_name       = azurerm_data_factory_pipeline.division.name

  interval  = 15
  frequency = "Minute"
}

resource "azurerm_data_factory_pipeline" "division" {
  name                = "pipeline1"
  resource_group_name = azurerm_resource_group.division.name
  data_factory_id     = azurerm_data_factory.division.id

  parameters = {
    name = "Cat"
  }

  activities_json = <<JSON
[
    {
        "name": "AzureFunction",
        "type": "AzureFunctionActivity",
        "dependsOn": [],
        "policy": {
            "timeout": "7.00:00:00",
            "retry": 0,
            "retryIntervalInSeconds": 30,
            "secureOutput": false,
            "secureInput": false
        },
        "userProperties": [],
        "typeProperties": {
            "functionName": {
                "value": "HttpTrigger1?name=@{pipeline().parameters.name}",
                "type": "Expression"
            },
            "method": "GET",
            "headers": {}
        },
        "linkedServiceName": {
            "referenceName": "AzureFunction1",
            "type": "LinkedServiceReference"
        }
    }
]
  JSON

  depends_on = [
    azurerm_data_factory_linked_service_azure_function.division,
  ]
}
