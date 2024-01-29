# Amazon ECS for Windows containers

Terraform module, which deploys an ECS cluster for Windows containers using Fargate Windows-based tasks. It is required to wait until Fargate tasks reach Running status before accessing the ALB DNS Name output.

## Providers

- hashicorp/aws | version = "~> 5.0"

## Variables description
- **ecs_windows_cluster_name (string)**: ECS Cluster name
- **ecsTaskExecutionRole_name (string)**: Name for the ECS task execution role
- **alb_ingress_name (string)**: Name for the ALB ingress security group
- **alb_ingress_ports (list(number))**: List of ports opened from Internet to ALB
- **ecs_fargate_task_name (string)**: Fargate task name
- **fargate_task_definition_name (string)**: Fargate task definition name
- **fargate_task_definition_cpu (number)**: Fargate task CPU count
- **fargate_task_definition_memory (number)**: Fargate task Memory count
- **fargate_task_definition_image (string)**: Windows container image
- **ecs_service_name (string)**: Name for the ECS service
- **desired_task_count (number)**: Desired tasks for the ECS service
- **alb_name (string)**: Name for the Application Load Balancer
- **alb_target_group_name (string)**: Name for the ALB target group - Only alphanumeric characters and hyphens allowed in name

## Usage

```hcl
module "ecs-windows" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/ecs-fargate-windows"

  alb_name           = "fargate-windows-2022-iis-alb"
  ecs_service_name   = "fargate-windows-2022-iis"
  desired_task_count = 2
}
```
## Outputs

- **aws_lb.ecs_alb.dns_name**: ALB DNS Name
