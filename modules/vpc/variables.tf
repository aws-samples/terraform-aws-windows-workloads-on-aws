## VPC CIDR BLOCK
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

## Private Subnet CIDR BLOCK
variable "private_subnets" {
  description = "Map of AZ to a number that should be used for private subnets"
  type        = map(number)

  default = {
    "us-east-1a" = 1
    "us-east-1b" = 2
  }
}

## Public Subnet CIDR BLOCK
variable "public_subnets" {
  description = "Map of AZ to a number that should be used for public subnets"
  type        = map(number)

  default = {
    "us-east-1a" = 3
    "us-east-1b" = 4
  }
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