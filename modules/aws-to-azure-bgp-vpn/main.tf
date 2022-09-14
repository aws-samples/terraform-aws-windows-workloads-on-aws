terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.29.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.21.1"
    }
  }
}