// Random storing for storage account name
resource "random_string" "storage_for_section" {
  length  = 22
  upper   = false
  special = false
  keepers = {
    resource_group_id = azurerm_resource_group.section.id
  }
}

// Storage account
resource "azurerm_storage_account" "section" {
  name                     = "st${random_string.storage_for_section.result}"
  location                 = azurerm_resource_group.section.location
  resource_group_name      = azurerm_resource_group.section.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
