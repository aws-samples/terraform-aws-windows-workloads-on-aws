terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["Sample VPC for Windows workloads on AWS"]
  }
  lifecycle {
    postcondition {
      condition     = self.enable_dns_support == true
      error_message = "The selected VPC must have DNS support enabled."
    }
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "aws_kms_alias" "fsx" {
  name = "alias/${var.fsx_kms_key}"
}

resource "aws_security_group" "ingress_tcp_fsx" {
  name        = "MAD-FSx.${var.managed_ad_fqdn}-Security-Group"
  description = "MAD FSx.${var.managed_ad_fqdn} Security Group"

  dynamic "ingress" {
    for_each = var.tcp_amazon_fsx_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "TCP"
      cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
    }
  }

  dynamic "ingress" {
    for_each = var.udp_amazon_fsx_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "UDP"
      cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
    }
  }

  ingress {
    description = "Dynamic ports"
    from_port   = "49152"
    to_port     = "65535"
    protocol    = "TCP"
    cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
  }

  egress {
    description = "Outbound to everywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MAD-FSx.${var.managed_ad_fqdn}-Security-Group"
  }
  vpc_id = data.aws_vpc.vpc_id.id
}

resource "aws_fsx_windows_file_system" "mad_fsx" {
  active_directory_id             = var.managed_ad_id
  aliases                         = ["MAD-FSx.${var.managed_ad_fqdn}"]
  automatic_backup_retention_days = var.automatic_backup_retention_days
  deployment_type                 = "SINGLE_AZ_1"
  kms_key_id                      = data.aws_kms_alias.fsx.arn
  security_group_ids              = [aws_security_group.ingress_tcp_fsx.id]
  skip_final_backup               = true
  storage_capacity                = var.storage_capacity
  storage_type                    = var.storage_type
  subnet_ids                      = concat(([data.aws_subnets.private_subnets.ids[0]]))
  tags = {
    Name = "MAD-FSx.${var.managed_ad_fqdn}"
  }
  throughput_capacity = var.throughput_capacity
}
