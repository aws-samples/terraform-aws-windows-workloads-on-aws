terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_windows_cluster_data.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_windows_cluster_data.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_windows_cluster_data.token
}

## Data

data "aws_eks_cluster" "eks_windows_cluster_ca" {
  name = aws_eks_cluster.eks_windows.name
}

output "kubeconfig-certificate-authority-data" {
  value = data.aws_eks_cluster.eks_windows_cluster_data.certificate_authority[0].data
}


data "aws_eks_cluster" "eks_windows_cluster_data" {
  name = aws_eks_cluster.eks_windows.name
}

data "aws_eks_cluster_auth" "eks_windows_cluster_data" {
  name = aws_eks_cluster.eks_windows.name
}

data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["VPC"]
  }
  lifecycle {
    postcondition {
      condition     = self.enable_dns_support == true
      error_message = "The selected VPC must have DNS support enabled."
    }
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "tag:Tier"
    values = ["Private"]
  }
}

data "tls_certificate" "eks_windows_cluster_tls" {
  url = aws_eks_cluster.eks_windows.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "eks_windows_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_iam_openid.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_iam_openid.arn]
      type        = "Federated"
    }
  }
}

data "aws_ami" "eks_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Core-EKS_Optimized-*"]
  }
}

data "aws_caller_identity" "account_id" {}

output "account_id" {
  value = data.aws_caller_identity.account_id.account_id
}

## Security Group

resource "aws_security_group" "cluster_sg" {
  name        = "cluster_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.vpc_id.id
}

resource "aws_security_group" "windows_sg" {
  name        = "windows_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.vpc_id.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "rule_worker_windows" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  source_security_group_id = aws_security_group.cluster_sg.id
  security_group_id        = aws_security_group.windows_sg.id
}

resource "aws_security_group_rule" "rule_control_plane" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  security_group_id        = aws_security_group.cluster_sg.id
  source_security_group_id = aws_security_group.windows_sg.id
}

## ECS IAM Roles and Instance Roles

resource "aws_iam_openid_connect_provider" "eks_iam_openid" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_windows_cluster_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_windows.identity[0].oidc[0].issuer
}

### EKS VPC CNI Role

resource "aws_iam_role" "eks_vpc_cni_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_windows_assume_role_policy.json
  name               = "eks-vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "eks_iam_role_attach_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_vpc_cni_role.name
}

### EKS Cluster - Role

resource "aws_iam_role" "eks_iam_role_cluster_service" {
  name = "eks-cluster-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_iam_role_cluster_service_attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ])
  role       = aws_iam_role.eks_iam_role_cluster_service.name
  policy_arn = each.value
}

### EKS Linux Node Group - Role
resource "aws_iam_role" "eks_node_group_role_linux" {
  name = "eks-node-group-linux-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_linux_node_group_role_attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  role       = aws_iam_role.eks_node_group_role_linux.name
  policy_arn = each.value
}

### EKS Windows Node Group - Role
resource "aws_iam_role" "eks_node_group_role_windows" {
  name = "eks-node-group-windows-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_windows_node_group_role_attach" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  role       = aws_iam_role.eks_node_group_role_windows.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "eks_windows_workernode_instance_profile" {
  name = var.eks_windows_workernode_instance_profile_name
  role = aws_iam_role.eks_node_group_role_windows.name
}

## EKS Cluster

resource "aws_eks_cluster" "eks_windows" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_iam_role_cluster_service.arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids = data.aws_subnets.private_subnets.ids
  }
}

## EKS Cluster Addon

resource "aws_eks_addon" "eks_windows_addon" {
  cluster_name = aws_eks_cluster.eks_windows.name
  addon_name   = "vpc-cni"
}

## Enable VPC CNI Windows Support

resource "kubernetes_config_map" "amazon_vpc_cni_windows" {
  depends_on = [
    aws_eks_cluster.eks_windows
  ]
  metadata {
    name      = "amazon-vpc-cni"
    namespace = "kube-system"
  }

  data = {
    enable-windows-ipam : "true"
  }
}

## AWS CONFIGMAP

resource "kubernetes_config_map" "configmap" {
  data = {
    "mapRoles" = <<EOT
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::${data.aws_caller_identity.account_id.account_id}:role/eks-node-group-linux-role
  username: system:node:{{EC2PrivateDNSName}}
- groups:
  - eks:kube-proxy-windows
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::${data.aws_caller_identity.account_id.account_id}:role/eks-node-group-windows-role
  username: system:node:{{EC2PrivateDNSName}}
EOT
  }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
}

## EKS Linux Node Group

resource "aws_eks_node_group" "node_group_linux" {
  cluster_name    = aws_eks_cluster.eks_windows.name
  node_group_name = "linux-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_group_role_linux.arn
  subnet_ids      = data.aws_subnets.private_subnets.ids
  depends_on = [
    aws_iam_role_policy_attachment.eks_linux_node_group_role_attach
  ]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 2
  }

  tags = {
    "name" = "eks-linux-node"
  }
}

## Windows Node group

resource "aws_launch_template" "eks_windows_nodegroup_lt" {
  name                   = "eks_windows_nodegroup_lt"
  vpc_security_group_ids = [aws_security_group.windows_sg.id, aws_security_group.cluster_sg.id]
  image_id               = data.aws_ami.eks_optimized_ami.id
  instance_type          = "t3.large"

  user_data = "${base64encode(<<EOF
<powershell>
[string]$EKSBinDir = "$env:ProgramFiles\Amazon\EKS"
[string]$EKSBootstrapScriptFile = "$env:ProgramFiles\Amazon\EKS\Start-EKSBootstrap.ps1"
& $EKSBootstrapScriptFile -EKSClusterName "${aws_eks_cluster.eks_windows.name}" -APIServerEndpoint "${aws_eks_cluster.eks_windows.endpoint}" -Base64ClusterCA "${data.aws_eks_cluster.eks_windows_cluster_data.certificate_authority[0].data}" -DNSClusterIP "10.100.0.10" 3>&1 4>&1 5>&1 6>&1
</powershell>

EOF
  )}"

  monitoring {
    enabled = false
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = "50"
      delete_on_termination = true
      volume_type           = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = { "kubernetes.io/cluster/${aws_eks_cluster.eks_windows.name}" = "owned", "kubernetes.io/os" = "windows", "name" = "eks-windows-node" }
  }

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.eks_windows_workernode_instance_profile.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  depends_on = [
    aws_eks_cluster.eks_windows
  ]
}

## Auto Scaling group

resource "aws_autoscaling_group" "eks-windows-nodegroup-asg" {

  name             = "Windows_worker_nodes_asg"
  desired_capacity = 1
  max_size         = 5
  min_size         = 1
  #target_group_arns = [var.external_alb_target_group_arn]
  launch_template {
    id      = aws_launch_template.eks_windows_nodegroup_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.private_subnets.ids
  health_check_type   = "EC2"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity, target_group_arns]
  }
}