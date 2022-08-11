# AWS Microsoft Route 53 Terraform module

Terraform module which create R53 Outbound Resolver Rules

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description

- **dns_ip1 (string)**: DNS IP address for target domain
  
- **dns_ip2 (bool)**: DNS IP address for target domain

- **domain_fqdn (string)**: The fully qualified name for the target domain, such as corp.example.com
   
- **resolver_endpoint_id (string)**: Endpoint ID of the R53 resolver the rule will be associated with

- **vpc_id (string)**: VPC ID of resolver endpoint

## Usage

```hcl
module "route53" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/route53-resolver-rule"

  dns_ip1 = "10.0.0.10"
  dns_ip2 = "10.0.0.11"
  domain_fqdn = "corp.local"
  resolver_endpoint_id = "rslvr-out-fdc049932dexample"
  vpc_id = "vpc-1234567890abcdefg"
}
```
## Outputs