data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["VPC"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}