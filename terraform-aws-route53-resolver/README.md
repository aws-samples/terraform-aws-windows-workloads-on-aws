# AWS Microsoft Route 53 Outbound Resolver Terraform module

Terraform module which creates an Route 53 Outbound Resolver

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description

- **r53_ports (number, string)**: Inbound Security Group ports. i.e. "ports, protocols, cidr"
  
- **subnet1_id (string)**: Subnet ID of resolver endpoint
  
- **subnet2_id (string)**: Subnet ID of resolver endpoint
  
- **vpc_id (string)**: VPC ID of resolver endpoint

## Usage

```hcl
module "route53-resolver" {
  source = "../route53-resolver"

  r53_ports = [
  {
    from_port   = 53
    to_port     = 53
    description = "DNS"
    protocol    = "TCP"
    cidr_blocks = "0.0.0.0/0"
  },
  {
    from_port   = 53
    to_port     = 53
    description = "DNS"
    protocol    = "UDP"
    cidr_blocks = "0.0.0.0/0"
  }
  ]
  subnet1_id = "subnet-1234567890abcdefg"
  subnet2_id = "subnet-1234567890abcdefg"
  vpc_id = "vpc-1234567890abcdefg"
}
```

## Outputs

- **resolver_endpoint_id**: Endpoint ID of the resolver which could be used to create R53 Resolver rules