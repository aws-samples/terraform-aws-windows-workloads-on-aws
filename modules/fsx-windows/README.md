# AWS Microsoft Managed AD Terraform module

Terraform module which deploys Amazon FSx for Windows Filesystem integrated with AWS Managed Microsoft AD

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description

- **automatic_backup_retention_days (number)**: The number of days to retain automatic backups. Minimum of 0 and maximum of 90

- **deployment_type (string)**: Specifies the file system deployment type, valid values are MULTI_AZ_1, SINGLE_AZ_1 and SINGLE_AZ_2

- **mad_domain_fqdn (string)**: FQDN of the AWS Managed Microsoft AD"

- **managedad_id (string)**: Directory ID of the AWS Managed Microsoft AD"

- **storage_capacity (number)**: Storage capacity (GiB) of the file system. Minimum of 32 and maximum of 65536

- **storage_type (string)**: Specifies the storage type, valid values are SSD and HDD

- **subnet_ids (list(string))**: Private subnet ID(s) for the Amazon FSx for Windows

- **throughput_capacity (number)**: Throughput (megabytes per second) of the file system in power of 2 increments. Minimum of 8 and maximum of 2048

- **vpc_id (map)**: VPC ID for the Amazon FSx for Windows

## Usage

```hcl
module "fsx-windows" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/fsx-windows"
  version = "1.0.2"

  automatic_backup_retention_days = 7
  deployment_type                 = "SINGLE_AZ_2"
  mad_domain_fqdn                 = "corp.example.com"
  managedad_id                    = "d-123456789"
  storage_capacity                = 32
  storage_type                    = "SSD"
  subnet_ids                      = ["subnet-12345678"]
  throughput_capacity             = 16
  vpc_id                          = "vpc-12345678"
}
```
## Outputs