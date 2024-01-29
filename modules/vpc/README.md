# Amazon VPC

Terraform module which deploys a VPC with private and public subnets, internet gateway, nat gateway, and routing.

## Providers

- hashicorp/aws | version = "~> 5.0"

## Variables description
- **vpc_cidr_block (string)**: The IPv4 CIDR block for the VPC
- **private_subnets (map(number))**: Map of AZ to a number that should be used for private subnets
- **public_subnets (map(number))**: Map of AZ to a number that should be used for public subnets


## Usage

```hcl
module "vpc" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/vpc"

  vpc_cidr_block = "10.0.0.0/16"
  private_subnets = {
    "us-east-1a" = 1
    "us-east-1b" = 2
  }
  public_subnets = {
    "us-east-1a" = 3
    "us-east-1b" = 4
  }
}
```
## Outputs

- **vpc_id**: Id of the VPC
- **private_subnets_id**: Ids of the private subnets
- **public_subnets_id**: Ids of the public subnets
- **private_subnets_cidr**: CIDR of the private subnets
- **public_subnets_cidr**: CIDR of the public subnets