# Workshop: Use Terraform to Build Microsoft Infrastructure on AWS (3 hours)
This code is used within an AWS workshop showing customers how to build Microsoft infrastructure on AWS using Terraform.

## Providers

- hashicorp/aws | version = "~> 3.70"

## Variables description
- **CustomerCode (string)**: 3 or 4 letter unique identifier for a customer
- **RnvironmentCode (string)**: 2 character code to signify the workloads environment
- **vpc_cidr (string)**: VPC CIDR range
- **region (string)**: AWS region
- **az_01 (string)**: Availability Zone 1
- **az_02 (string)**: Availability Zone 2
- **EnvironmentTag (string)**: Environment name tag
- **CustomerTag (string)**: Customer name tag


## Usage

:warning: **Warning**: This code is not designed for consumption outside of an AWS workshop setting. It contains errors, relies on pre-provisioned resources and lacks production security controls.

## Outputs

none