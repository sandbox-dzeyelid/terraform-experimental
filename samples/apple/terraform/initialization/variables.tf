variable "shared_resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "japaneast"
}

variable "shared_mssql_server_name" {
  type = string
}

variable "shared_mssql_server_administrator_login_name" {
  type = string
}

variable "shared_mssql_server_administrator_login_password" {
  type      = string
  sensitive = true
}
