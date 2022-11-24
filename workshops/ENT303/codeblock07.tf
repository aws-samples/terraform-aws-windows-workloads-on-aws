# Set VPC DHCP options for domain members
resource "aws_vpc_dhcp_options" "mmad01" {
  domain_name         = aws_directory_service_directory.mmad01.name
  domain_name_servers = aws_directory_service_directory.mmad01.dns_ip_addresses

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "dhc", var.environment_code, "mmad", "01"),
    resourcetype = "network"
    codeblock    = "codeblock07"
  }
}

resource "aws_vpc_dhcp_options_association" "mmad01" {
  vpc_id          = aws_vpc.vpc_01.id
  dhcp_options_id = aws_vpc_dhcp_options.mmad01.id
}

# Windows Domain join SSM setup
resource "aws_ssm_document" "domainjoin" {
  name          = format("%s%s%s%s", var.customer_code, "ssm", var.environment_code, "domainjoin")
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "Join instances to domain based on tag"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId"    = aws_directory_service_directory.mmad01.id,
            "directoryName"  = aws_directory_service_directory.mmad01.name,
            "dnsIpAddresses" = aws_directory_service_directory.mmad01.dns_ip_addresses
          }
        }
      ]
    }
  )

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "ssm", var.environment_code, "domainjoin")
    resourcetype = "identity"
    codeblock    = "codeblock07"
  }
}

resource "aws_ssm_association" "domainjoin" {
  name = aws_ssm_document.domainjoin.name
  targets {
    key    = "tag:domainjoin"
    values = ["mmad"]
  }
}
# IAM policy configuration
resource "aws_iam_role_policy_attachment" "ssm-mmad" {
  role       = aws_iam_role.websrv.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

# LaunchTemplate
resource "aws_launch_template" "websrv" {
  name                   = format("%s%s%s%s", var.customer_code, "ltp", var.environment_code, "websrv01")
  description            = "Launch Template for Windows IIS Web server Auto Scaling Group"
  image_id               = "ami-04e0ebd20d57a72c1"
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.ec2_keypair_01.key_name
  vpc_security_group_ids = [aws_security_group.app01.id]
  ebs_optimized          = true

  user_data = base64encode(templatefile("webserver_user_data.ps1",
    {
      S3Bucket = "s3://${aws_s3_bucket.websrv.bucket}/webserverfiles/"
    }
    )
  )

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp1"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.websrv.id
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name         = format("%s%s%s%s", var.customer_code, "ec2", var.environment_code, "websrvasg")
      domainjoin   = "mmad"
      resourcetype = "compute"
      codeblock    = "codeblock07"
    }
  }
}
