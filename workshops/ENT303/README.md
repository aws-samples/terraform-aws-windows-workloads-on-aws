# Workshop: Use Terraform to Build Microsoft Infrastructure on AWS (3 hours)
This code is used within the [Use Terraform to build Microsoft infrastructure on AWS](https://studio.us-east-1.prod.workshops.aws/workshops/e5122482-ded0-4259-94f0-c373f23c5257)workshop.

In this workshop, explore how to use Terraform to deploy services such as Amazon EC2 for Windows Server, AWS Managed Microsoft Active Directory, Amazon FSx for Windows File Server, and Amazon RDS for SQL Server. Learn from best practices for how to use Terraform to create fully functioning, well-architected AWS solutions in a quick and repeatable manner.

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