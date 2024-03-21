## Providers settings

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

## Data

data "aws_elastic_beanstalk_solution_stack" "net_windows" {
  most_recent = true
  name_regex  = "^64bit Windows Server 2022 (.*) running IIS (.*)$"
}

data "aws_vpc" "default_vpc_id" {
  default = true

  lifecycle {
    postcondition {
      condition     = self.enable_dns_support == true
      error_message = "The selected VPC must have DNS support enabled."
    }
  }
}

data "aws_subnets" "default_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc_id.id]
  }

  tags = {
    Tier = "Private"
  }
}

data "aws_subnets" "default_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc_id.id]
  }

  tags = {
    Tier = "Public"
  }
}

## IAM resources

resource "aws_iam_role" "beanstalk_net_windows_ec2_role" {
  name                = "iam_beanstalk_net_windows_ec2_role"
  path                = "/"
  managed_policy_arns = local.managedpolicies_beanstalk_service_ec2_role

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "beanstalk_net_windows_instance_profile" {
  name = "iam_beanstalk_net_windows_instance_profile"
  role = aws_iam_role.beanstalk_net_windows_ec2_role.name
}

resource "aws_iam_role" "beanstalk_net_windows_role" {
  name                = "iam_beanstalk_net_windows_instance_role"
  path                = "/"
  managed_policy_arns = local.managedpolicies_beanstalk_service_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      },
    ]
  })
}

## Security groups

resource "aws_security_group" "secgroup_beanstalk_elb" {
  name        = "secgroup_beanstalk_elb"
  description = "Allows traffic to ELB resources"
  vpc_id      = var.vpc_id == null ? data.aws_vpc.default_vpc_id.id : var.vpc_id

  dynamic "ingress" {
    for_each = local.inbound_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP/HTTPS inbound from anyhwere"
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all outbound"
  }

  tags = var.tags
}

resource "aws_security_group" "secgroup_beanstalk_net_windows" {
  name        = "secgroup_beanstalk_net_windows"
  description = "Allows traffic to Beanstalk resources"
  vpc_id      = var.vpc_id == null ? data.aws_vpc.default_vpc_id.id : var.vpc_id

  dynamic "ingress" {
    for_each = local.inbound_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      description = "Allow HTTP/HTTPS inbound from the ELB security group"

      security_groups = [
        "${aws_security_group.secgroup_beanstalk_elb.id}",
      ]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all outbound"
  }

  tags = var.tags
}

## Beanstalk deployment (Windows + ASP.NET sample)

resource "aws_elastic_beanstalk_application" "net_windows_application" {
  name        = var.beanstalk_net_windows_application_name
  description = var.beanstalk_net_windows_application_description

  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk_net_windows_role.arn
    max_count             = 128
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_environment" "net_windows_environment" {
  name                = var.beanstalk_net_windows_environment_name
  application         = aws_elastic_beanstalk_application.net_windows_application.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.net_windows.name
  cname_prefix        = replace(var.beanstalk_net_windows_application_name, " ", "-")

  dynamic "setting" {
    for_each = local.eb_environment_settings
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }

  tags = var.tags
}

# Sets HTTP to HTTPS redirect at the ALB when var.acm_arn is not null

data "aws_lb_listener" "http_listener" {

  load_balancer_arn = aws_elastic_beanstalk_environment.net_windows_environment.load_balancers[0]
  port              = 80
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count = var.acm_arn == null ? 0 : 1

  listener_arn = data.aws_lb_listener.http_listener.arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}