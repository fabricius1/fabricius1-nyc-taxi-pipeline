resource "azurerm_storage_account" "adlg2" {
  name                     = "fabricioproject3"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  tags = local.terraform_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "landzones" {
  for_each = {
    for i, v in ["raw", "curated", "enriched"] : "${v}" => "${i + 1}-${v}"
  }
  name               = each.value
  storage_account_id = azurerm_storage_account.adlg2.id
}

resource "azurerm_storage_blob" "config_file" {
  name                   = "config/nyc_taxi_config.xlsx"
  storage_account_name   = azurerm_storage_account.adlg2.name
  storage_container_name = azurerm_storage_data_lake_gen2_filesystem.landzones["raw"].name
  type                   = "Block"
  source                 = "extra_files/nyc_taxi_config.xlsx"
}

resource "azurerm_storage_share" "fileshare1" {
  name                 = "cloudshell"
  storage_account_name = azurerm_storage_account.adlg2.name
  access_tier          = "TransactionOptimized"
  quota                = 1
}