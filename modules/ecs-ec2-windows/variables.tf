## ECS Cluster

variable "ecs_windows_cluster_name" {
  type        = string
  default     = "ECS-Windows"
  description = "Name for the ECS cluster"
}

## ECS IAM Roles and Instance Roles

variable "ecsTaskExecutionRole_name" {
  type        = string
  default     = "ecs_windows_ecsTaskExecutionRole"
  description = "Name for the ECS task execution role"
}

variable "ecsInstanceRole_name" {
  type        = string
  default     = "ecs_windows_ecsInstanceRole"
  description = "Name for the ECS container instance IAM role"
}

variable "ecs_windows_ecsInstanceRole_profile_name" {
  type        = string
  default     = "ecs_windows_ecsInstanceRole_profile"
  description = "Name for the ECS windows instance profile"
}

## Security Group

variable "alb_ingress_name" {
  type        = string
  default     = "ECS - Application Load Balancer - Ingress"
  description = "Name for the ALB ingress security group"
}

variable "ecs_container_instances_ingress_name" {
  type        = string
  default     = "ecs_container_instances_ingress"
  description = "Name for the ECS container instances security group"
}

variable "alb_ingress_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "List of ports opened from Internet to ALB"
}

variable "container_instances_ingress_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "List of ports opened from ALB to Container Instances"
}

## Launch Template

variable "launch_template_name" {
  type        = string
  default     = "ECS_Windows_LT"
  description = "Name for the launch template"
}

variable "ec2_instance_types" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type"
}

## Auto Scaling Group

variable "asg_name" {
  type        = string
  default     = "ASG_ECS_Windows"
  description = "Name for the Auto Scaling Group"
}

variable "asg_desired_capacity" {
  type        = number
  default     = 2
  description = "Desired capacity for the Auto Scaling Group"
}

variable "asg_max_size" {
  type        = number
  default     = 100
  description = "Maximum capacity for the Auto Scaling Group"
}

variable "asg_min_size" {
  type        = number
  default     = 1
  description = "Minimum capacity for the Auto Scaling Group"
}

## ECS Task Definitions

### Fargate Task_Definition

variable "fargate_task_definition_name" {
  type        = string
  default     = "iis_fargate"
  description = "Name for the Fargate task definition"
}

variable "fargate_task_definition_cpu" {
  type        = number
  default     = "1024"
  description = "CPU for the Fargate task definition"
}

variable "fargate_task_definition_memory" {
  type        = number
  default     = "2048"
  description = "Memory for the Fargate task definition"
}

variable "fargate_task_definition_image" {
  type        = string
  default     = "mcr.microsoft.com/windows/servercore/iis:latest"
  description = "Container image for the Fargate task definition"
}

### EC2 Task_Definition

variable "ec2_task_definition_name" {
  type        = string
  default     = "iis_ec2"
  description = "Name for the EC2 task definition"
}

variable "ec2_task_definition_cpu" {
  type        = number
  default     = "1024"
  description = "CPU for the EC2 task definition"
}

variable "ec2_task_definition_memory" {
  type        = number
  default     = "1024"
  description = "Memory for the EC2 task definition"
}

variable "ec2_task_definition_image" {
  type        = string
  default     = "mcr.microsoft.com/windows/servercore/iis:latest"
  description = "Container image for the EC2 task definition"
}

## ECS Service

variable "ecs_service_name" {
  type        = string
  default     = "ecs_service_windows"
  description = "Name for the ECS service"
}

variable "desired_task_count" {
  type        = number
  default     = "2"
  description = "Desired tasks for the ECS service"
}

## ALB

variable "alb_name" {
  type        = string
  default     = "ecs-alb"
  description = "Name for the Application Load Balancer"
}

## ALB Target Group

variable "alb_target_group_name" {
  type        = string
  default     = "ecs-alb-target-group"
  description = "Name for the ALB target group - Only alphanumeric characters and hyphens allowed in name"
}