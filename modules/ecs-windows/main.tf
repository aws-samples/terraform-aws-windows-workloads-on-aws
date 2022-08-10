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

## ECS IAM Roles and Instance Roles

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

resource "aws_iam_role" "ecsInstanceRole" {
  name                = var.ecsInstanceRole_name
  path                = "/"
  managed_policy_arns = local.managedpolicies_AmazonEC2ContainerServiceforEC2Role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
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

resource "aws_iam_instance_profile" "ecs_windows_ecsInstanceRole_profile" {
  name = var.ecs_windows_ecsInstanceRole_profile_name
  role = aws_iam_role.ecsInstanceRole.name
}

## Security Groups

resource "aws_security_group" "alb_ingress" {
  name        = var.alb_ingress_name
  description = "Ingress traffic from Internet"
  vpc_id      = data.aws_vpc.vpc_id.id

  dynamic "ingress" {
    for_each = var.alb_ingress_ports
    
    content {
      description = "Ingress traffic from Internet"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = local.tcp_protocol
      cidr_blocks = local.all_ips_ipv4
    }
  }

  egress {
    description = "Egress traffic to anywhere"
    from_port        = local.any_port
    to_port          = local.any_port
    protocol         = local.any_protocol
    cidr_blocks      = local.all_ips_ipv4
    ipv6_cidr_blocks = local.all_ips_ipv6
  }
}

resource "aws_security_group" "ecs_container_instances_ingress" {
  name        = var.ecs_container_instances_ingress_name
  description = "Ingress traffic from ALB to Container Instance - Dynamic Ports"
  vpc_id      = data.aws_vpc.vpc_id.id

  ingress {
      description = "Dynamic ports allows from ALB Security Group"
      from_port       = 32768
      to_port         = 65535
      protocol        = "tcp"
      security_groups = [aws_security_group.alb_ingress.id]
    }

  egress {
    description = "Dynamic ports allowed outbound"
    from_port        = local.any_port
    to_port          = local.any_port
    protocol         = local.any_protocol
    cidr_blocks      = local.all_ips_ipv4
    ipv6_cidr_blocks = local.all_ips_ipv6
  }
}

## Launch Template 

data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Core-ECS_Optimized-*"]
  }
}

resource "aws_launch_template" "ecs_container_instances" {
  name                   = var.launch_template_name
  image_id               = data.aws_ami.ecs_optimized_ami.id
  instance_type          = var.ec2_instance_types
  vpc_security_group_ids = [aws_security_group.ecs_container_instances_ingress.id]
  update_default_version = true

  lifecycle {
    create_before_destroy = true
  }

  metadata_options {
      http_endpoint = "enabled"
      http_tokens   = "required"
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_windows_ecsInstanceRole_profile.name
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 50
    }
  }
  user_data = "${base64encode(<<EOF
<powershell>
Initialize-ECSAgent -Cluster ${aws_ecs_cluster.ecs_windows_cluster.name} -EnableTaskIAMRole -AwsvpcBlockIMDS -EnableTaskENI -LoggingDrivers '["json-file","awslogs"]'
[Environment]::SetEnvironmentVariable("ECS_ENABLE_AWSLOGS_EXECUTIONROLE_OVERRIDE",$TRUE, "Machine")
</powershell>
EOF
  )}"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ECS Windows - Container Instance"
    }
  }
}

## Auto_Scaling_Group

resource "aws_autoscaling_group" "asg_ecs_cluster" {
  name                = var.asg_name
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  vpc_zone_identifier = data.aws_subnets.private_subnets.ids
  force_delete        = true
  enabled_metrics     = local.asg_metrics
  
  launch_template {
    id      = aws_launch_template.ecs_container_instances.id
    version = aws_launch_template.ecs_container_instances.latest_version
  }


  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "aws-eks"
    value               = "aws-eks"
    propagate_at_launch = true
  }
}

## ECS Task_Definitions (Optional)

### Fargate Task_Definition

resource "aws_ecs_task_definition" "fargate_task_definition_iis" {
  family                   = var.fargate_task_definition_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.fargate_task_definition_cpu
  memory                   = var.fargate_task_definition_memory
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "iis_fargate",
    "image": "${var.fargate_task_definition_image}",
    "cpu": 1024,
    "memory": 2048,
    "essential": true
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "WINDOWS_SERVER_2019_CORE"
    cpu_architecture        = "X86_64"
  }
}

### EC2 Task_Definition

resource "aws_ecs_task_definition" "ec2_task_definition_iis" {
  family                   = var.ec2_task_definition_name
  execution_role_arn       = aws_iam_role.ecsInstanceRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  cpu                      = var.ec2_task_definition_cpu
  memory                   = var.ec2_task_definition_memory
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "iis_ec2"
      image     = var.ec2_task_definition_image
      cpu       = var.ec2_task_definition_cpu
      memory    = var.ec2_task_definition_memory
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
        }
      ]
    }
  ])
}

# ## Amazon ECS Service

resource "aws_ecs_service" "ecs_ec2" {
  name                   = var.ecs_service_name
  cluster                = aws_ecs_cluster.ecs_windows_cluster.id
  task_definition        = aws_ecs_task_definition.ec2_task_definition_iis.id
  desired_count          = var.desired_task_count
  enable_execute_command = true
  scheduling_strategy    = "REPLICA"
  launch_type            = "EC2"
  depends_on             = [aws_launch_template.ecs_container_instances]

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
    container_name   = "iis_ec2"
    container_port   = 80
  }

  ordered_placement_strategy {
    field = "cpu"
    type  = "binpack"
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
  enable_deletion_protection       = true
  drop_invalid_header_fields       = true
  access_logs {
  bucket = var.access_logs_bucket
  prefix  = "ecs-lb"
  enabled = true
 }
}

## ALB Target Group

resource "aws_lb_target_group" "ecs_alb_target_group" {
  name                          = var.alb_target_group_name
  target_type                   = "instance"
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

## AWS CloudWatch Metrics

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${aws_ecs_cluster.ecs_windows_cluster.name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_ecs_cluster.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.1s", var.ec2_instance_types) == "t" ? 1 : 0 #If Instance is T-Series, enable CPU Credit Balance metric

  alarm_name  = "${aws_ecs_cluster.ecs_windows_cluster.name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_ecs_cluster.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}