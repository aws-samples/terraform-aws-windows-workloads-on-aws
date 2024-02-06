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

## Data
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

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Public"]
  }
}

## ECS Windows Cluster

resource "aws_ecs_cluster" "ecs_windows_cluster" {
  name = var.ecs_windows_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

## ECS IAM Role

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name                = var.ecsTaskExecutionRole_name
  path                = "/"
  managed_policy_arns = local.managedpolicies_AmazonECSTaskExecutionRolePolicy

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

## Security Groups

resource "aws_security_group" "alb_ingress" {
  name        = var.alb_ingress_name
  description = "Ingress traffic from Internet"
  vpc_id      = data.aws_vpc.vpc_id.id

  dynamic "ingress" {
    for_each = var.alb_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = local.tcp_protocol
      cidr_blocks = local.all_ips_ipv4
    }
  }

  egress {
    from_port        = local.any_port
    to_port          = local.any_port
    protocol         = local.any_protocol
    cidr_blocks      = local.all_ips_ipv4
    ipv6_cidr_blocks = local.all_ips_ipv6
  }
}

resource "aws_security_group" "ecs_fargate_task_ingress" {
  name        = "Security Group for ECS Fargate Windows task"
  description = "Ingress traffic from ALB to Fargate task"
  vpc_id      = data.aws_vpc.vpc_id.id

  ingress {
    description     = "HTTP Port"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_ingress.id]
  }

  egress {
    from_port        = local.any_port
    to_port          = local.any_port
    protocol         = local.any_protocol
    cidr_blocks      = local.all_ips_ipv4
    ipv6_cidr_blocks = local.all_ips_ipv6
  }
}

### Fargate Task_Definition

resource "aws_ecs_task_definition" "fargate_task_definition_iis" {
  family                   = var.fargate_task_definition_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_task_definition_cpu
  memory                   = var.fargate_task_definition_memory
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = jsonencode([{
    name      = "iis_fargate"
    image     = "${var.fargate_task_definition_image}"
    essential = true
    portMappings = [{
      protocol      = "tcp"
      containerPort = 80
      hostPort      = 80
    }]
    }]
  )

  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2022_CORE"
    cpu_architecture        = "X86_64"
  }
}

## Amazon ECS Service

resource "aws_ecs_service" "ecs_fargate" {
  name                   = var.ecs_service_name
  cluster                = aws_ecs_cluster.ecs_windows_cluster.id
  task_definition        = aws_ecs_task_definition.fargate_task_definition_iis.id
  desired_count          = var.desired_task_count
  enable_execute_command = true
  scheduling_strategy    = "REPLICA"
  launch_type            = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.private_subnets.ids
    security_groups  = [aws_security_group.ecs_fargate_task_ingress.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
    container_name   = "iis_fargate"
    container_port   = 80
  }
}

## ALB

resource "aws_lb" "ecs_alb" {
  name                   = var.alb_name
  internal               = false
  load_balancer_type     = "application"
  security_groups        = [aws_security_group.alb_ingress.id]
  subnets                = data.aws_subnets.public_subnets.ids
  idle_timeout           = 60
  enable_http2           = true
  desync_mitigation_mode = "defensive"
}

## ALB Target Group

resource "aws_lb_target_group" "ecs_alb_target_group" {
  name                          = var.alb_target_group_name
  target_type                   = "ip"
  port                          = 80
  protocol                      = "HTTP"
  vpc_id                        = data.aws_vpc.vpc_id.id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

## ALB Target Group Listerner

resource "aws_alb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
  }
}
