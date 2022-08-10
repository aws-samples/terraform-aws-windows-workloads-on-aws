## Providers settings

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-bootcamp"
}

## Data

data "aws_elastic_beanstalk_solution_stack" "net_framework" {
  most_recent = true
  name_regex  = "^64bit Windows Server 2019 (.*) running IIS (.*)$"
}

data "aws_vpc" "selected_vpc" {
  id = var.vpc_id

  lifecycle {
    postcondition {
      condition     = self.enable_dns_support == true
      error_message = "The selected VPC must have DNS support enabled."
    }
  }
}

## IAM resources

resource "aws_iam_role" "beanstalk_net_framework_ec2_role" {
  name                = "iam_beanstalk_net_framework_ec2_role"
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

resource "aws_iam_instance_profile" "beanstalk_net_framework_instance_profile" {
  name = "iam_beanstalk_net_framework_instance_profile"
  role = aws_iam_role.beanstalk_net_framework_ec2_role.name
}

resource "aws_iam_role" "beanstalk_net_framework_role" {
  name                = "iam_beanstalk_net_framework_instance_role"
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

## Security group

resource "aws_security_group" "secgroup_beanstalk_net_framework" {
  name        = "secgroup_beanstalk_net_framework"
  description = "Allows traffic to Beanstalk resources"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.inbound_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.selected_vpc.cidr_block]
      description = "Allow HTTP/HTTP inbound"
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Allow all outbound"
  }

  tags = var.tags
}

## Beanstalk deployment (Windows + .NET Framework sample)

resource "aws_elastic_beanstalk_application" "net_framework_application" {
  name        = var.beanstalk_net_framework_application_name
  description = var.beanstalk_net_framework_application_description

  appversion_lifecycle {
    service_role          = aws_iam_role.beanstalk_net_framework_role.arn
    max_count             = 128
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_environment" "net_framework_environment" {
  name                = var.beanstalk_net_framework_environment_name
  application         = aws_elastic_beanstalk_application.net_framework_application.name
  solution_stack_name = data.aws_elastic_beanstalk_solution_stack.net_framework.name
  cname_prefix        = replace(var.beanstalk_net_framework_application_name, " ", "-")

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.private_subnets)
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_net_framework_instance_profile.name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = false
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", var.public_subnets)
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200,300,301,302,303,304,307,308" # HTTP OK and redirect codes
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application" # [classic, application, network]
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.ec2_instance_type
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.secgroup_beanstalk_net_framework.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = var.key_name
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public" # [public, internal]
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.asg_min_instances
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.asg_max_instances
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = true
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = 7
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = var.acm_arn == "" ? "false" : "true"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.acm_arn
  }

  tags = var.tags
}

# Sets HTTP redirect to HTTPS at the ALB when var.acm_arn is not null

data "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_elastic_beanstalk_environment.net_framework_environment.load_balancers[0]
  port              = 80
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count = var.acm_arn == "" ? 0 : 1

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