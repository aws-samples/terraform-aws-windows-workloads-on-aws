# ENT303 Workshop: Use Terraform to Build Microsoft Infrastructure on AWS (2 hours)
This code is used within an AWS workshop showing customers how to build Microsoft infrastructure on AWS with Terraform.

## Providers

- hashicorp/aws | version = "~> 3.70"

## Variables description
- **customer_code (string)**: 3 or 4 letter unique identifier for a customer
- **environment_code (string)**: 2 character code to signify the workloads environment
- **vpc_cidr (string)**: VPC CIDR range
- **region (string)**: AWS region
- **az_01 (string)**: Availability Zone 1
- **az_02 (string)**: Availability Zone 2
- **az_03 (string)**: Availability Zone 3
- **ami_id01 (string)**: AMI ID for Amazon provided Microsoft Windows Server 2022 base
- **environment (string)**: Environment name tag
- **customer (string)**: Customer name tag


## Usage

:warning: **Warning**: This code is not designed for consumption outside of an AWS workshop setting. It contains errors, relies on pre-provisioned resources and lacks production security controls.

## Outputs

none