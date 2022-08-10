locals {
  internet = "0.0.0.0/0"

  managedpolicies_AmazonEC2ContainerServiceforEC2Role = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  managedpolicies_AmazonECSTaskExecutionRolePolicy = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

  vpce = [
    "com.amazonaws.us-east-1.ecs",
    "com.amazonaws.us-east-1.ecs-agent",
    "com.amazonaws.us-east-1.ecs-telemetry",
    "com.amazonaws.us-east-1.ecr.api",
    "com.amazonaws.us-east-1.ecr.dkr"
  ]

  asg_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
    "GroupInServiceCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTotalCapacity",
    "WarmPoolDesiredCapacity",
    "WarmPoolWarmedCapacity",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
  ]
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips_ipv4 = ["0.0.0.0/0"]
  all_ips_ipv6 = ["::/0"]
}

