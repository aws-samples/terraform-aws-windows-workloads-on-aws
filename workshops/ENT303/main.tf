terraform {
  required_providers {

    aws = {

      source  = "hashicorp/aws"
      version = "~> 3.70"

    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {

  profile = "default"
  region  = var.region

  default_tags {

    tags = {

      customer    = var.customer
      environment = var.environment
      provisioner = "terraform"
      workshop    = "pdo"

    }
  }

}
