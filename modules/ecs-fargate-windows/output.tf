##  ALB DNS Name

output "alb_dns_name" {
  value = aws_lb.ecs_alb.dns_name
}
