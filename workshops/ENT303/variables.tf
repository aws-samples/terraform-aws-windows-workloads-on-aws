# Naming Convention
variable "CustomerCode" {
  description = "3 or 4 letter unique identifier for a customer"
  type        = string
}

variable "EnvironmentCode" {
  description = "2 character code to signify the workloads environment"
  type        = string
}

# Network Variables
variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
}

# Regions
variable "region" {
  description = "AWS region"
  type        = string
}

variable "az_01" {
  description = "Availability Zone 1"
  type        = string
}

variable "az_02" {
  description = "Availability Zone 2"
  type        = string
}

# Tags
variable "EnvironmentTag" {
  description = "Environment name tag"
  type        = string
}

variable "CustomerTag" {

  description = "Customer Name tag"
  type        = string
}