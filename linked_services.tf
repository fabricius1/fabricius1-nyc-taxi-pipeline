# linked service to website base url
resource "azurerm_data_factory_linked_custom_service" "ls_http_nyc_taxi" {
  name                 = "ls_http_nyc_taxi"
  data_factory_id      = azurerm_data_factory.adf.id
  type                 = "HttpServer"
  description          = "Connect to base url from nyc taxi data website"
  type_properties_json = <<JSON
  {
    "url": "https://d37ci6vzurychx.cloudfront.net/trip-data/",
    "enableServerCertificateValidation": true,
    "authenticationType": "Anonymous"
  }
JSON
}

# linked service to data lake:
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "ls_datalake" {
  name                = "ls_datalake"
  data_factory_id     = azurerm_data_factory.adf.id
  storage_account_key = var.adlsg2_key
  url                 = "https://${azurerm_storage_account.adlg2.name}.dfs.core.windows.net/"
}
