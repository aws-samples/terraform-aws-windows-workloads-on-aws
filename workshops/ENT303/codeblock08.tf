# Use this code in M02 TASK01

# EC2 Auto Scaling Group
resource "aws_autoscaling_group" "websrv" {
  name                    = format("%s%s%s%s", var.customer_code, "asg", var.environment_code, "websrv01")
  default_cooldown        = 60
  target_group_arns       = [aws_lb_target_group.websrv.arn]
  vpc_zone_identifier     = [aws_subnet.priv_subnet_01.id,aws_subnet.priv_subnet_02.id]
  desired_capacity        = 2
  max_size                = 4
  min_size                = 2

  launch_template {
    id      = aws_launch_template.websrv.id
    version = "$Latest"
  }
}

# EC2 Auto Scaling Policy
resource "aws_autoscaling_policy" "websrv" {
  name                      = format("%s%s%s%s", var.customer_code, "asp", var.environment_code, "websrv01")
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.websrv.name
  estimated_instance_warmup = 100

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }
}
