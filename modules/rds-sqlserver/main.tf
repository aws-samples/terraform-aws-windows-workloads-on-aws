terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

## Data
data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["VPC"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "aws_subnet_ids" "private_subnets_ids" {
  vpc_id = data.aws_vpc.vpc_id.id
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}


## Security Groups

resource "aws_security_group" "rdssql_ingress" {
  name        = var.rdssql_ingress_name
  description = "Ingress traffic from Private subnets"
  vpc_id      = data.aws_vpc.vpc_id.id

  dynamic "ingress" {
    for_each = var.rdssql_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.vpc_id.cidr_block]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

## VPC Endpoints

resource "aws_vpc_endpoint" "rds_vpc_endpoint" {
  vpc_id              = data.aws_vpc.vpc_id.id
  subnet_ids          = data.aws_subnet_ids.private_subnets_ids.ids
  service_name        = "com.amazonaws.us-east-1.rds-data"
  vpc_endpoint_type   = "Interface"
  auto_accept         = true
  security_group_ids  = [aws_security_group.rdssql_ingress.id]
  private_dns_enabled = true

}

## DB Subnet Group

resource "aws_db_subnet_group" "rdssqldb_subnet_group" {
  name       = var.rdssql_db_subnet_group_name
  subnet_ids = data.aws_subnet_ids.private_subnets_ids.ids
}

## IAM Role for Domain join

resource "aws_iam_role" "rdssql_iam_role" {
  name                = "rdssql_iam_role"
  path                = "/"
  managed_policy_arns = var.ManagedPolicy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

## Amazon RDS for SQL Server

resource "aws_db_instance" "rds_sql_server" {
  engine         = var.rdssql_engine[0]
  engine_version = var.rdssql_engine_version[0]
  license_model  = "license-included"
  port           = 1433

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = false

  timezone           = var.time_zone
  character_set_name = var.sql_collation

  backup_window            = var.backup_windows_retention_maintenance[0]
  backup_retention_period  = var.backup_windows_retention_maintenance[1]
  maintenance_window       = var.backup_windows_retention_maintenance[2]
  delete_automated_backups = true
  skip_final_snapshot      = true
  deletion_protection      = false

  db_subnet_group_name = aws_db_subnet_group.rdssqldb_subnet_group.name

  instance_class = var.rds_db_instance_class

  allocated_storage     = var.storage_allocation[0]
  max_allocated_storage = var.storage_allocation[1]
  storage_type          = "gp2"
  storage_encrypted     = false

  username = var.user_name
  password = var.rdssql_password

  multi_az               = false
  vpc_security_group_ids = [aws_security_group.rdssql_ingress.id]
}