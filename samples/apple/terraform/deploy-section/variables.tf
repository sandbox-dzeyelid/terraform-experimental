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

variable "sections" {
  type = list(object({
    name                = string
    resource_identifier = string
    github_configuration = object({
      account_name    = string
      branch_name     = string
      git_url         = string
      repository_name = string
      root_folder     = string
    })
  }))
  default = []
}
