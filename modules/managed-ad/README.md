# AWS Microsoft Managed AD Terraform module

Terraform module which manages AWS Microsoft Managed AD resources.

## Providers

- hashicorp/aws | version = "~> 4.0"
- hashicorp/random | version = "~>3.3.0"

## Variables description

- **ds_managed_ad_directory_name (string)**: Full Qualified Domain Name (FQDN) for the Managed AD. i.e. "corp.local"

- **ds_managed_ad_short_name (string)**: Active Directory Forest NetBIOS name. i.e. "corp.local"

- **ds_managed_ad_edition (string)**: AWS Microsoft Managed AD edition, either _Standard_ or _Enterprise_. Default = _Standard_

- **ds_managed_ad_vpc_id (string)**: VPC ID where Managed AD should be deployed

- **ds_managed_ad_subnet_ids (list(string))**: Two private subnet IDs where Managed AD Domain Controllers should be set

## Usage

```hcl
module "managed-ad" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/managed-ad"

  ds_managed_ad_directory_name = "corp.local"
  ds_managed_ad_short_name     = "corp"
  ds_managed_ad_edition        = "Standard"
  ds_managed_ad_vpc_id         = "vpc-123456789"
  ds_managed_ad_subnet_ids     = ["subnet-12345678", "subnet-87654321"]
}
```

## Outputs

- **ds_managed_ad_id**: AWS Microsoft Managed AD ID

- **ds_managed_ad_ips**:? AWS Microsoft Managed AD DNS IPs

- **managed_ad_password_secret_id**: Admin password is set as an entry on AWS Secrets Manager as _${var.ds_managed_ad_directory_name}_admin_