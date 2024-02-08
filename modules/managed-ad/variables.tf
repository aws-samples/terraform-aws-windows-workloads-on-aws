variable "aws_region" {
  type = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "The VPC id to deploy the AWS Managed Microsoft AD directory"
}

variable "private_subnet_id_1" {
  type        = string
  description = "The private subnet ID - 1"
}

variable "private_subnet_id_2" {
  type        = string
  description = "The private subnet ID - 2"
}

variable "ds_managed_ad_directory_name" {
  type        = string
  description = "The fully qualified domain name for the AWS Managed Microsoft AD directory, such as corp.example.com"
}

variable "ds_managed_ad_short_name" {
  type        = string
  description = "The NetBIOS name for the AWS Managed Microsoft AD directory, such as CORP"
}


variable "ds_managed_ad_edition" {
  type        = string
  default     = "Standard"
  description = "The AWS Managed Microsoft AD edition: Enterprise or Standard (default)"
  validation {
    condition     = contains(["Enterprise", "Standard"], var.ds_managed_ad_edition)
    error_message = "The edition value must be Enterprise or Standard."
  }
}

variable "ds_managed_ad_secret_key" {
  type        = string
  description = "ARN or Id of the AWS KMS key to be used to encrypt the secret values in the versions stored in this secret"
}