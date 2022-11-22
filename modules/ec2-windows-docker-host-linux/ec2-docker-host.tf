data "aws_ami" "amazon-linux-2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "docker_host_sg" {
  name        = "docker_host_sg"
  description = "allow incomming traffic to docker from VPC"

  vpc_id = data.aws_vpc.main.id
  ingress {
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    from_port   = var.docker_host_port
    to_port     = var.docker_host_port
    protocol    = "TCP"
    description = "Ingress docker port"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Egress all"
  }
}

resource "aws_instance" "docker_host" {
  ami                  = data.aws_ami.amazon-linux-2.id
  instance_type        = var.docker_host_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2admin.id
  monitoring           = true
  ebs_optimized        = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  root_block_device {
    volume_size = 20
    encrypted   = true
  }

  vpc_security_group_ids = [aws_security_group.docker_host_sg.id]
  key_name               = var.docker_host_key_pair

  tags = {
    "Name" = "docker_host"
  }

  subnet_id = data.aws_subnets.private_subnets.ids[0]
  user_data = base64encode(templatefile("${path.module}/assets/docker-host-init.sh", {
    docker_host_port = var.docker_host_port
  }))
}