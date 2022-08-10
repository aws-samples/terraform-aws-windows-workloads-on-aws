## VPC ID

output "vpc_id" {
  value = aws_vpc.vpc.id
}

## Subnet IDs

output "private_subnets_id" {
  value = values(aws_subnet.private_subnets).*.id
}

output "public_subnets_id" {
  value = values(aws_subnet.public_subnets).*.id
}

## Subnets CIDRs

output "private_subnets_cidr" {
  value = values(aws_subnet.private_subnets).*.cidr_block
}

output "public_subnets_cidr" {
  value = values(aws_subnet.public_subnets).*.cidr_block
}