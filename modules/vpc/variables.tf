## VPC CIDR BLOCK
variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
  description = "The IPv4 CIDR block for the VPC"
}

## Private Subnet CIDR BLOCK
variable "private_subnets" {
  type        = map(number)
  default = {
    "us-east-1a" = 1
    "us-east-1b" = 2
  }
  description = "Map of AZ to a number that should be used for private subnets"
}

## Public Subnet CIDR BLOCK
variable "public_subnets" {
  type        = map(number)
  default = {
    "us-east-1a" = 3
    "us-east-1b" = 4
  }
  description = "Map of AZ to a number that should be used for public subnets"
}



# locals {
#   availability_zone = slice(data.aws_availability_zones.az.names, 0, 1)
# }

# locals {
#   availability_zone = slice(data.aws_availability_zones.az.names, 0, 1)
# }

# locals {
#   value = join(",", slice(data.aws_availability_zones.az.names, 0, 2))
# }