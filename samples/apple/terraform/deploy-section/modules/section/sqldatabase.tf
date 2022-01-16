// data: sql server
data "azurerm_mssql_server" "shared" {
  name                = var.shared_mssql_server_name
  resource_group_name = var.shared_resource_group_name
}

// sql database
resource "azurerm_mssql_database" "section" {
  name        = "sqldb-${var.resource_identifier}"
  server_id   = data.azurerm_mssql_server.shared.id
  collation   = "Japanese_CI_AS"
  max_size_gb = 250
  sku_name    = "S0"
}
