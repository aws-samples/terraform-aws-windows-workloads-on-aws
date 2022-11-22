data "aws_ami" "windows_ec2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

resource "aws_instance" "dev_env" {
  depends_on = [
    aws_instance.docker_host
  ]

  ami                  = data.aws_ami.windows_ec2.id
  instance_type        = "m5.large"
  iam_instance_profile = aws_iam_instance_profile.ec2admin.id
  monitoring           = true
  ebs_optimized        = true

  root_block_device {
    volume_size = 60
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  key_name = var.windows_key_pair

  vpc_security_group_ids = [aws_security_group.docker_host_sg.id]

  tags = {
    "Name"                 = "dev_env"
    "docker-host-instance" = aws_instance.docker_host.id
  }

  subnet_id = data.aws_subnets.private_subnets.ids[0]
  user_data = base64encode(templatefile("${path.module}/assets/dev-env-init.ps1", {
    docker_host_ip   = aws_instance.docker_host.private_ip
    docker_host_port = var.docker_host_port
  }))
}

resource "aws_ec2_tag" "docker_host_instance_id" {
  depends_on = [
    aws_instance.docker_host
  ]

  resource_id = aws_instance.docker_host.id
  key         = "dev-env-instance"
  value       = aws_instance.dev_env.id
}
