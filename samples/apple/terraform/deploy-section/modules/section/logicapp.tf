resource "azurerm_logic_app_workflow" "section" {
  name                = "logic-${var.resource_identifier}"
  location            = azurerm_resource_group.section.location
  resource_group_name = azurerm_resource_group.section.name
}
