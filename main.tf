terraform {
  required_version = ">=1.3.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.29.1"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}