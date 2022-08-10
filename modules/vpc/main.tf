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

data "aws_availability_zones" "az" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

## VPC

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.private_subnets
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)
  availability_zone = each.key

  tags = {
    Subnet = "Private Subnet ${each.key}-${each.value}"
    Name   = "Private Subnet / ${each.key}"
    Tier   = "Private"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id            = aws_vpc.vpc.id
  for_each          = var.public_subnets
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)
  availability_zone = each.key

  tags = {
    Subnet = "${each.key}-${each.value}"
    Name   = "Public Subnet / ${each.key}"
    Tier   = "Public"
  }
}

## Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

## Elastic IP for Nat Gateway

resource "aws_eip" "eip_natgateway" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "Elastic IP for Nat Gateway"
  }
}

## Nat Gateway

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_natgateway.id
  # subnet_id     = aws_subnet.public_subnets["us-east-1a"].id 
  subnet_id  = aws_subnet.public_subnets[element(keys(aws_subnet.public_subnets), 0)].id #Accessing an specific value inside a for_each
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "Nat Gateway"
  }
}

## Route Tables

resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = local.internet
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "private_subnet_route_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_subnets_route_table.id
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = local.internet
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_route_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_subnets_route_table.id
}