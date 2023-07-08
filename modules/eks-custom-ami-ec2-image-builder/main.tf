terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.region
}

## Data
data "aws_ami" "eks_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Core-EKS_Optimized-${var.eks_cluster_version}-*"]
  }
}

## This data source was built to work with the VPC module provided with this registry.

data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["VPC"]
  }
  lifecycle {
    postcondition {
      condition     = self.enable_dns_support == true
      error_message = "The selected VPC must have DNS support enabled."
    }
  }
}

## This data source was built to work with the subnets in the VPC module provided with this registry.

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

## IAM Role and Instance Profile

resource "aws_iam_role" "eks_imagebuilder_role" {
  name                = "eks-imagebuilder-role"
  path                = "/"
  managed_policy_arns = local.managedpolicies_EC2ImageBuilder
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "eks_imagebuilder_instance_profile" {
  name = "eks-imagebuilder-instance-profile"
  role = aws_iam_role.eks_imagebuilder_role.name
}

### SSM VPC Endpoint if needed

# resource "aws_vpc_endpoint" "ssm_vpc_endpoint" {
#   vpc_id = data.aws_vpc.vpc_id.id
#   for_each = toset([
#     "com.amazonaws.${var.region}.ssm",
#     "com.amazonaws.${var.region}.ssmmessages",
#     "com.amazonaws.${var.region}.ec2messages"
#   ])
#   service_name = each.value
#   vpc_endpoint_type = "Interface"
#   security_group_ids = [
#     aws_security_group.ec2_security_group.id
#   ]
#   private_dns_enabled = true
# }

## Security Group

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-imagebuilder-sg"
  description = "EC2 Image Builder SG - No inbound traffic"
  vpc_id      = data.aws_vpc.vpc_id.id

  egress {
    from_port        = local.any_port
    to_port          = local.any_port
    protocol         = local.any_protocol
    cidr_blocks      = local.all_ips_ipv4
    ipv6_cidr_blocks = local.all_ips_ipv6
  }
}

## Image Recipe

resource "aws_imagebuilder_image_recipe" "eks_custom_ami" {
  name         = var.image_recipe_name
  parent_image = data.aws_ami.eks_optimized_ami.id
  version      = var.image_recipe_version
  block_device_mapping {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_size           = 100
      volume_type           = "gp3"
    }
  }
  component {
    component_arn = aws_imagebuilder_component.container_images.arn
  }
}

## Image Components

resource "aws_imagebuilder_component" "container_images" {
  name                  = var.component_name_image_cache
  platform              = "Windows"
  version               = "1.0.0"
  change_description    = "Cache .NET Framework container images to accelerate Windows container startup time"
  supported_os_versions = ["Microsoft Windows"]
  data = yamlencode({
    phases = [{
      name = "build"
      steps = [{
        action = "ExecutePowerShell"
        inputs = {
          commands = [
            "Set-ExecutionPolicy Unrestricted -Force",
            "ctr -n k8s.io image pull mcr.microsoft.com/windows/servercore:ltsc2019",
            "ctr -n k8s.io image pull mcr.microsoft.com/dotnet/framework/aspnet:4.8",
            "ctr -n k8s.io image pull mcr.microsoft.com/dotnet/framework/runtime:4.8"
          ]
        }
        name = "containerdpull"
      }]
    }]
    schemaVersion = 1.0
  })
}

resource "aws_imagebuilder_infrastructure_configuration" "custom_windows_ami_infrastructure" {
  name                          = "EKS Custom Windows optimized AMI"
  description                   = "EC2 Image Builder Infrastructure for Amazon EKS Windows custom AMIs"
  instance_profile_name         = aws_iam_instance_profile.eks_imagebuilder_instance_profile.name
  instance_types                = ["t3.large", "t3.xlarge"]
  subnet_id                     = data.aws_subnets.private_subnets.ids[0]
  security_group_ids            = [aws_security_group.ec2_security_group.id]
  terminate_instance_on_failure = true
  #key_pair                      = "yourkeeppair"
}

resource "aws_imagebuilder_distribution_configuration" "custom_windows_ami_distribution" {
  name        = "EKS Custom Windows optimized AMI"
  description = "EC2 Image Builder Distribution for Amazon EKS Windows custom AMIs"

  distribution {
    region = var.region
    fast_launch_configuration {
      enabled               = true
      account_id            = data.aws_caller_identity.current.account_id
      max_parallel_launches = var.fast_launch_max_parallel_launches
      snapshot_configuration {
        target_resource_count = var.snapshot_configuration_target_resource_count
      }
    }
    ami_distribution_configuration {
      ami_tags = {
        "Orchestrator" = "Amazon EKS"
      }
    }
  }
}

resource "aws_imagebuilder_image_pipeline" "custom_ami_pipeline" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.eks_custom_ami.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.custom_windows_ami_infrastructure.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.custom_windows_ami_distribution.arn
  description                      = "EC2 Image Builder Pipeline for Amazon EKS Windows custom AMIs"
  name                             = "EKS Custom Windows optimized AMI"
  enhanced_image_metadata_enabled  = false

  schedule {
    schedule_expression = "cron(0 0 * * ? *)"
    timezone            = var.image_pipeline_timezone
  }
}