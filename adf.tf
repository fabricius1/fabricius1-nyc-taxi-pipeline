resource "azurerm_data_factory" "adf" {
  name                = "adf-terraform"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.terraform_tags

  depends_on = [
    azurerm_storage_account.adlg2,
    azurerm_storage_data_lake_gen2_filesystem.landzones #,
    # azurerm_storage_blob.config_file,
    # azurerm_storage_share.fileshare1
  ]
}

# pipeline to process a single file
resource "azurerm_data_factory_pipeline" "pl_process_single_file" {
  name            = "pl_process_single_file"
  data_factory_id = azurerm_data_factory.adf.id

  parameters = {
    "year"     = ""
    "filename" = ""
  }

  depends_on = [
    azurerm_data_factory_dataset_parquet.ds_parquet_website,
    azurerm_data_factory_dataset_parquet.ds_parquet_datalake
  ]

  activities_json = <<JSON
[
  {
    "name": "Copy data1",
    "type": "Copy",
    "dependsOn": [],
    "policy": {
      "timeout": "0.12:00:00",
      "retry": 0,
      "retryIntervalInSeconds": 30,
      "secureOutput": false,
      "secureInput": false
    },
    "userProperties": [],
    "typeProperties": {
      "source": {
          "type": "ParquetSource",
          "storeSettings": {
              "type": "HttpReadSettings",
              "requestMethod": "GET"
          }
      },
      "sink": {
          "type": "ParquetSink",
          "storeSettings": {
              "type": "AzureBlobFSWriteSettings"
          },
          "formatSettings": {
              "type": "ParquetWriteSettings"
          }
      },
      "enableStaging": false,
      "translator": {
          "type": "TabularTranslator",
          "typeConversion": true,
          "typeConversionSettings": {
              "allowDataTruncation": true,
              "treatBooleanAsNumber": false
          }
      }
    },
    "inputs": [
      {
        "referenceName": "ds_parquet_website_source",
        "type": "DatasetReference",
        "parameters": {
          "filename": {
            "value": "@pipeline().parameters.filename",
            "type": "Expression"
          }
        }
      }
    ],
    "outputs": [
      {
        "referenceName": "ds_parquet_datalake_sink",
        "type": "DatasetReference",
        "parameters": {
          "filename": {
            "value": "@pipeline().parameters.filename",
            "type": "Expression"
          },
          "year": {
            "value": "@pipeline().parameters.year",
            "type": "Expression"
          }
        }
      }
    ]
  }
]
  JSON
}

# main pipeline
resource "azurerm_data_factory_pipeline" "pl_main" {
  name            = "pl_main"
  data_factory_id = azurerm_data_factory.adf.id

  depends_on = [
    azurerm_data_factory_custom_dataset.ds_config_excel,
    azurerm_data_factory_pipeline.pl_process_single_file
  ]

  activities_json = <<JSON
[
    {
        "name": "filenames_list",
        "type": "Lookup",
        "dependsOn": [],
        "policy": {
            "timeout": "0.12:00:00",
            "retry": 0,
            "retryIntervalInSeconds": 30,
            "secureOutput": false,
            "secureInput": false
        },
        "userProperties": [],
        "typeProperties": {
            "source": {
                "type": "ExcelSource",
                "storeSettings": {
                    "type": "AzureBlobFSReadSettings",
                    "recursive": false,
                    "enablePartitionDiscovery": false
                }
            },
            "dataset": {
                "referenceName": "ds_config_excel",
                "type": "DatasetReference"
            },
            "firstRowOnly": false
        }
    },
    {
        "name": "ForEach1",
        "type": "ForEach",
        "dependsOn": [
            {
                "activity": "filenames_list",
                "dependencyConditions": [
                    "Succeeded"
                ]
            }
        ],
        "userProperties": [],
        "typeProperties": {
            "items": {
                "value": "@activity('filenames_list').output.value",
                "type": "Expression"
            },
            "isSequential": true,
            "activities": [
                {
                    "name": "Execute Pipeline1",
                    "type": "ExecutePipeline",
                    "dependsOn": [],
                    "userProperties": [],
                    "typeProperties": {
                        "pipeline": {
                            "referenceName": "pl_process_single_file",
                            "type": "PipelineReference"
                        },
                        "waitOnCompletion": true,
                        "parameters": {                            
                          "filename": {
                            "value": "@item().filename",
                            "type": "Expression"
                          },
                          "year": {
                            "value": "@item().year",
                            "type": "Expression"
                          }
                        }
                    }
                }
            ]
        }
    }
]
JSON
}
