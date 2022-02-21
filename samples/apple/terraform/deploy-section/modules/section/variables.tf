variable "resource_identifier" {
  type = string
}

variable "location" {
  type    = string
  default = "japaneast"
}

variable "shared_resource_group_name" {
  type = string
}

variable "shared_mssql_server_name" {
  type = string
}

variable "shared_mssql_server_administrator_login_password" {
  type      = string
  sensitive = true
}

variable "azure_data_factory_github_configurations" {
  type = list(object({
    account_name    = string
    branch_name     = string
    git_url         = string
    repository_name = string
    root_folder     = string
  }))
  default = []
}
