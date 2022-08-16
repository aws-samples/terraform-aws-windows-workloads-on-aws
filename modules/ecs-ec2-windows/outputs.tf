##  Security Group ID

output "alb_security_group_id" {
  value = aws_security_group.alb_ingress.id
}

output "ecs_container_instances_security_group_id" {
  value = aws_security_group.ecs_container_instances_ingress.id
}

## Launch Template ID

output "ecs_launch_template_output" {
  value = aws_launch_template.ecs_container_instances.id
}