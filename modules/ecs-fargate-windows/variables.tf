## ECS Cluster

variable "ecs_windows_cluster_name" {
  type    = string
  default = "ECS-Windows"
}

## ECS IAM Roles and Instance Roles

variable "ecsTaskExecutionRole_name" {
  type    = string
  default = "ecs_windows_ecsTaskExecutionRole"
}

## Security Group

variable "alb_ingress_name" {
  type    = string
  default = "ECS - Application Load Balancer - Ingress"
}

variable "ecs_fargate_task_name" {
  type    = string
  default = "iis_fargate"
}

variable "alb_ingress_ports" {
  type        = list(number)
  description = "List of ports opened from Internet to ALB"
  default     = [80, 443]
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