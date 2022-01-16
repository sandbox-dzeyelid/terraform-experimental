data "azurerm_function_app_host_keys" "section" {
  name                = local.function_app_name
  resource_group_name = azurerm_resource_group.section.name

  depends_on = [
    azurerm_function_app.section,
  ]
}

// Data factory
resource "azurerm_data_factory" "section" {
  name                = "adf-${var.resource_identifier}"
  location            = azurerm_resource_group.section.location
  resource_group_name = azurerm_resource_group.section.name
}

resource "azurerm_data_factory_linked_service_azure_function" "section" {
  name                = "AzureFunction1"
  resource_group_name = azurerm_resource_group.section.name
  data_factory_id     = azurerm_data_factory.section.id
  url                 = "https://${azurerm_function_app.section.default_hostname}"
  key                 = data.azurerm_function_app_host_keys.section.default_function_key
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "section" {
  name                = "BlobStorage1"
  resource_group_name = azurerm_resource_group.section.name
  data_factory_id     = azurerm_data_factory.section.id
  connection_string   = azurerm_storage_account.section.primary_blob_connection_string
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "section" {
  name                = "SqlDatabase1"
  resource_group_name = azurerm_resource_group.section.name
  data_factory_id     = azurerm_data_factory.section.id

  connection_string = "Integrated Security=False;Data Source=${data.azurerm_mssql_server.shared.fully_qualified_domain_name};Initial Catalog=${azurerm_mssql_database.section.name};User ID=${data.azurerm_mssql_server.shared.administrator_login};Password=${var.shared_mssql_server_administrator_login_password}"
}

resource "azurerm_data_factory_trigger_schedule" "section" {
  name                = "trigger1"
  resource_group_name = azurerm_resource_group.section.name
  data_factory_id     = azurerm_data_factory.section.id
  pipeline_name       = azurerm_data_factory_pipeline.section.name

  interval  = 15
  frequency = "Minute"
}

resource "azurerm_data_factory_pipeline" "section" {
  name                = "pipeline1"
  resource_group_name = azurerm_resource_group.section.name
  data_factory_id     = azurerm_data_factory.section.id

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
    azurerm_data_factory_linked_service_azure_function.section,
  ]
}
