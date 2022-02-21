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

  dynamic "github_configuration" {
    for_each = var.azure_data_factory_github_configurations
    content {
      account_name    = github_configuration.value.account_name
      branch_name     = github_configuration.value.branch_name
      git_url         = github_configuration.value.git_url
      repository_name = github_configuration.value.repository_name
      root_folder     = github_configuration.value.root_folder
    }
  }
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
