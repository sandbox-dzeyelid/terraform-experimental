output "shared_resource_group_name" {
  value = azurerm_resource_group.shared.name
}

output "shared_mssql_server_name" {
  value = azurerm_mssql_server.shared.name
}

output "shared_mssql_server_administrator_login_password" {
  value     = var.shared_mssql_server_administrator_login_password
  sensitive = true
}
