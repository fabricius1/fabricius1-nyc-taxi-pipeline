resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = var.synapse_workspace_name
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = var.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.landzones["raw"].id
  sql_administrator_login              = var.adminuser
  sql_administrator_login_password     = var.password
  managed_resource_group_name          = "mrg-${var.synapse_workspace_name}"

  aad_admin {
    login     = "AzureAD Admin"
    object_id = var.object_id
    tenant_id = var.tenant_id
  }

  identity {
    type = "SystemAssigned"
  }
}