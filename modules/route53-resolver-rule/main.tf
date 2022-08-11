terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "aws_route53_resolver_rule" "r53_outbound_resolver_rule" {
  domain_name          = var.domain_fqdn
  name                 = replace("VPC-Outbound-Resolver-Rule-${var.domain_fqdn}", ".", "-")
  rule_type            = "FORWARD"
  resolver_endpoint_id = var.resolver_endpoint_id
  tags = {
    Name = replace("VPC-Outbound-Resolver-Rule-${var.domain_fqdn}", ".", "-")
  }
  target_ip {
    ip = var.dns_ip1
  }
  target_ip {
    ip = var.dns_ip2
  }
}

resource "aws_route53_resolver_rule_association" "r53_outbound_resolver_rule_association" {
  name             = replace("VPC-Outbound-Resolver-Rule-Assoc-${var.domain_fqdn}", ".", "-")
  resolver_rule_id = aws_route53_resolver_rule.r53_outbound_resolver_rule.id
  vpc_id           = var.vpc_id
}