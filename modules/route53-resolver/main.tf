terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

locals {
  r53_protocols = [
    "TCP",
    "UDP"
  ]
}

resource "aws_security_group" "r53_outbound_resolver_sg" {
  name        = "VPC-Outbound-Resolver-SG-${var.vpc_id}"
  description = "VPC-Outbound-Resolver-SG-${var.vpc_id}"

  dynamic "egress" {
    for_each = local.r53_protocols
    iterator = r53_protocol
    content {
      description = "DNS"
      from_port   = 53
      to_port     = 53
      protocol    = r53_protocol.value
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = "VPC-Outbound-Resolver-SG-${var.vpc_id}"
  }
  vpc_id = var.vpc_id
}

resource "aws_route53_resolver_endpoint" "r53_outbound_resolver" {
  name               = "VPC-Outbound-Resolver-${var.vpc_id}"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.r53_outbound_resolver_sg.id]
  ip_address {
    subnet_id = var.subnet1_id
  }
  ip_address {
    subnet_id = var.subnet2_id
  }
  tags = {
    Name = "VPC-Outbound-Resolver-${var.vpc_id}"
  }
}
