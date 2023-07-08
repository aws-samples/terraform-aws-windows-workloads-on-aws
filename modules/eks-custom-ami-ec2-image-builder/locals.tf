locals {
  # Security Groups locals
  any_port     = 0
  any_protocol = "-1"
  all_ips_ipv4 = ["0.0.0.0/0"]
  all_ips_ipv6 = ["::/0"]

  # IAM Policies for Image Builder Infrastructure role
  managedpolicies_EC2ImageBuilder = [
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder",
    "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}