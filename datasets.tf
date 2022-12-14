# dataset to excel config file
resource "azurerm_data_factory_custom_dataset" "ds_config_excel" {
  name            = "ds_config_excel"
  data_factory_id = azurerm_data_factory.adf.id
  type            = "Excel"

  linked_service {
    name = azurerm_data_factory_linked_service_data_lake_storage_gen2.ls_datalake.name
  }

  type_properties_json = <<JSON
  {
    "location": {
        "type": "AzureBlobFSLocation",
        "fileName": "nyc_taxi_config.xlsx",
        "folderPath": "config",
        "fileSystem": "1-raw"
    },
    "sheetIndex": 0,
    "firstRowAsHeader": true
  }
JSON
}

# source dataset to parquet file in NYC Taxi Data site
resource "azurerm_data_factory_dataset_parquet" "ds_parquet_website" {
  name                = "ds_parquet_website_source"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_custom_service.ls_http_nyc_taxi.name
  compression_codec   = "snappy"

  parameters = {
    "filename" = ""
  }

  http_server_location {
    relative_url             = "@dataset().filename"
    filename                 = "/"
    dynamic_filename_enabled = true
  }
}

# # sink dataset to parquet file in the datalake
resource "azurerm_data_factory_dataset_parquet" "ds_parquet_datalake" {
  name                = "ds_parquet_datalake_sink"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.ls_datalake.name
  compression_codec   = "snappy"

  parameters = {
    "year"     = ""
    "filename" = ""
  }

  azure_blob_storage_location {
    container                = "1-raw"
    path                     = "@concat('yellow_tripdata/', dataset().year)"
    filename                 = "@dataset().filename"
    dynamic_path_enabled     = true
    dynamic_filename_enabled = true
  }
}