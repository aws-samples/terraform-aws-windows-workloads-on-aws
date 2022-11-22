terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.35"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}