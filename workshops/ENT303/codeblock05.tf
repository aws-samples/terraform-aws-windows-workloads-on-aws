#Load Balancer
resource "aws_lb" "websrv" {
  name_prefix        = format("%s%s", var.customer_code, "alb") #cannot be longer than 6 characters
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web01.id]
  subnets            = [aws_subnet.pub_subnet_01.id,aws_subnet.pub_subnet_02.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.websrv.id
    prefix  = "albaccesslogs"
    enabled = true
  }

    tags = {
      Name         = format("%s%s%s%s", var.customer_code, "alb", var.environment_code, "websrv01")
      resourcetype = "network"
      codeblock    = "codeblock05"
    }
}

resource "aws_lb_target_group" "websrv" {
  name                          = format("%s%s%s%s", var.customer_code, "ltg", var.environment_code, "websrv01")
  target_type                   = "instance"
  port                          = 80
  protocol                      = "TCP"
  vpc_id                        = aws_vpc.vpc_01.id
  load_balancing_algorithm_type = "round_robin"

  stickiness  {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }

    tags = {
      Name         = format("%s%s%s%s", var.customer_code, "ltg", var.environment_code, "websrv01")
      resourcetype = "task05"
      codeblock    = "codeblock05"
    }
}

##CORRUPTED## "websrv" {
##CORRUPTED## 
##CORRUPTED## 
##CORRUPTED## 

  default_action {
    type             = "forward"
##CORRUPTED## 
  }
}
