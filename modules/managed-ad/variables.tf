variable "ds_managed_ad_directory_name" {
  type        = string
  description = "The fully qualified domain name for the AWS Managed Microsoft AD directory, such as corp.example.com"
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
  default     = "aws/secretsmanager"
  description = "ARN or Id of the AWS KMS key to be used to encrypt the secret values in the versions stored in this secret"
}

variable "ds_managed_ad_short_name" {
  type        = string
  description = "The NetBIOS name for the AWS Managed Microsoft AD directory, such as CORP"
}

variable "ds_managed_ad_subnet_ids" {
  type        = list(string)
  description = "Two private subnet IDs for the AWS Managed Microsoft AD"
}

variable "ds_managed_ad_vpc_id" {
  type        = string
  description = "VPC ID for the AWS Managed Microsoft AD"
}
