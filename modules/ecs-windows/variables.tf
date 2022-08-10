## ECS Cluster

variable "ecs_windows_cluster_name" {
  type    = string
  default = "ECS-Windows"
}

variable "access_logs_bucket" {
  type    = string
  default = "alb_access_logs_bucket"
}

## ECS IAM Roles and Instance Roles

variable "ecsTaskExecutionRole_name" {
  type    = string
  default = "ecs_windows_ecsTaskExecutionRole"
}

variable "ecsInstanceRole_name" {
  type    = string
  default = "ecs_windows_ecsInstanceRole"
}

variable "ecs_windows_ecsInstanceRole_profile_name" {
  type    = string
  default = "ecs_windows_ecsInstanceRole_profile"
}

## Security Group

variable "alb_ingress_name" {
  type    = string
  default = "ECS - Application Load Balancer - Ingress"
}

variable "ecs_container_instances_ingress_name" {
  type    = string
  default = "ecs_container_instances_ingress"
}

variable "alb_ingress_ports" {
  type        = list(number)
  description = "List of ports opened from Internet to ALB"
  default     = [80, 443]
}

variable "container_instances_ingress_ports" {
  type        = list(number)
  description = "List of ports opened from ALB to Container Instances"
  default     = [80, 443]
}

## Launch Template

variable "launch_template_name" {
  type    = string
  default = "ECS_Windows_LT"
}

variable "ec2_instance_types" {
  type    = string
  default = "t3.medium"
}

## Auto Scaling Group

variable "asg_name" {
  type    = string
  default = "ASG_ECS_Windows"
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 100
}

variable "asg_min_size" {
  type    = number
  default = 1
}

## ECS Task Definitions

### Fargate Task_Definition

variable "fargate_task_definition_name" {
  type    = string
  default = "iis_fargate"
}

variable "fargate_task_definition_cpu" {
  type    = number
  default = "1024"
}

variable "fargate_task_definition_memory" {
  type    = number
  default = "2048"
}

variable "fargate_task_definition_image" {
  type    = string
  default = "mcr.microsoft.com/windows/servercore/iis:latest"
}

### EC2 Task_Definition

variable "ec2_task_definition_name" {
  type    = string
  default = "iis_ec2"
}

variable "ec2_task_definition_cpu" {
  type    = number
  default = "1024"
}

variable "ec2_task_definition_memory" {
  type    = number
  default = "1024"
}

variable "ec2_task_definition_image" {
  type    = string
  default = "mcr.microsoft.com/windows/servercore/iis:latest"
}

## ECS Service

variable "ecs_service_name" {
  type    = string
  default = "ecs_service_windows"
}

variable "desired_task_count" {
  type    = number
  default = "2"
}

## ALB

variable "alb_name" {
  type    = string
  default = "ecs-alb"
}

## ALB Target Group

variable "alb_target_group_name" {
  type        = string
  default     = "ecs-alb-target-group"
  description = "Only alphanumeric characters and hyphens allowed in name"
}