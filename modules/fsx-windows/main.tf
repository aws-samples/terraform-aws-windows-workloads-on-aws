terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_kms_alias" "fsx" {
  name = "alias/${var.fsx_kms_key}"
}

locals {
  fsx_ports = [
    {
      from_port   = 445
      to_port     = 445
      description = "SMB"
      protocol    = "TCP"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    },
    {
      from_port   = 5985
      to_port     = 5986
      description = "WinRM"
      protocol    = "TCP"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    }
  ]
}

resource "aws_security_group" "fsx" {
  name        = "MAD-FSx.${var.managed_ad_fqdn}-Security-Group"
  description = "MAD FSx.${var.managed_ad_fqdn} Security Group"

  dynamic "ingress" {
    for_each = local.fsx_ports
    iterator = fsx_ports
    content {
      description = fsx_ports.value.description
      from_port   = fsx_ports.value.from_port
      to_port     = fsx_ports.value.to_port
      protocol    = fsx_ports.value.protocol
      cidr_blocks = [fsx_ports.value.cidr_blocks]
    }
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
  vpc_id = var.vpc_id
}

resource "aws_fsx_windows_file_system" "mad_fsx" {
  active_directory_id             = var.managed_ad_id
  aliases                         = ["MAD-FSx.${var.managed_ad_fqdn}"]
  automatic_backup_retention_days = var.automatic_backup_retention_days
  deployment_type                 = var.deployment_type
  kms_key_id                      = data.aws_kms_alias.fsx.arn
  preferred_subnet_id             = var.subnet_ids[0]
  security_group_ids              = [aws_security_group.fsx.id]
  skip_final_backup               = true
  storage_capacity                = var.storage_capacity
  storage_type                    = var.storage_type
  subnet_ids                      = var.subnet_ids
  tags = {
    Name = "MAD-FSx.${var.managed_ad_fqdn}"
  }
  throughput_capacity = var.throughput_capacity
}
