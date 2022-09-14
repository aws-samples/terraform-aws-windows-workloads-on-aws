// AWS Provider Version https://registry.terraform.io/providers/hashicorp/aws/latest
// Azure Provider Version https://registry.terraform.io/providers/hashicorp/azurerm/3.16.0
provider "aws" {
  region = var.aws_location
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
