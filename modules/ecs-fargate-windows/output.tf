##  Security Group ID

output "alb_url" {
  value = aws_lb.ecs_alb.dns_name
}
