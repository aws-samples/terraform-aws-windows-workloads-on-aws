# Amazon ECS for Windows containers

Terraform module which deploys an ECS cluster for Windows containers. 

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description
- **ecs_windows_cluster_name (string)**: Name for the ECS cluster
- **access_logs_bucket (string)**: Bucket for storing the ALB access logs
- **ecsTaskExecutionRole_name (string)**: Name for the ECS task execution role
- **ecsInstanceRole_name (string)**: Name for the ECS container instance IAM role
- **ecs_windows_ecsInstanceRole_profile_name (string)**: Name for the ECS windows instance profile
- **alb_ingress_name (string)**: Name for the ALB ingress security group
- **ecs_container_instances_ingress_name (string)**: Name for the ECS container instances security group
- **alb_ingress_ports (list(number))**: List of ports opened from Internet to ALB
- **container_instances_ingress_ports ()**: List of ports opened from ALB to Container Instances
- **launch_template_name (string)**: Name for the launch template
- **ec2_instance_types (string)**: EC2 instance type
- **asg_name (string)**: Name for the Auto Scaling Group
- **asg_desired_capacity (number)**: Desired capacity for the Auto Scaling Group
- **asg_max_size (number)**: Maximum capacity for the Auto Scaling Group
- **asg_min_size (number)**: Minimum capacity for the Auto Scaling Group
- **fargate_task_definition_name (string)**: Name for the Fargate task definition
- **fargate_task_definition_cpu (number)**:  CPU for the Fargate task definition
- **fargate_task_definition_memory (number)**: Memory for the Fargate task definition
- **fargate_task_definition_image (string)**: Container image for the Fargate task definition
- **ec2_task_definition_name (string)**: Name for the EC2 task definition
- **ec2_task_definition_cpu (number)**: CPU for the EC2 task definition
- **ec2_task_definition_memory (number)**: Memory for the EC2 task definition
- **ec2_task_definition_image (string)**: Container image for the EC2 task definition
- **ecs_service_name (string)**: Name for the ECS service
- **desired_task_count (number)**: Desired tasks for the ECS service
- **alb_name (string)**: Name for the Application Load Balancer
- **alb_target_group_name (string)**: Name for the ALB target group - Only alphanumeric characters and hyphens allowed in name


## Usage

```hcl
module "ecs-windows" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/ecs-windows"
  version = "1.0.2"

  alb_name           = "ecs-alb"
  ecs_service_name   = "ecs_service_windows"
  desired_task_count = 2
}
```
## Outputs

- **alb_security_group_id**: Security group ID
- **ecs_container_instances_security_group_id**: ECS Container instances security group ID
- **ecs_launch_template_output**: ECS launch template output
