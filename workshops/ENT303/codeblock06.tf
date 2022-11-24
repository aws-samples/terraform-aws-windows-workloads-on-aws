# Create a private key for use with EC2 instances

resource "tls_private_key" "ec2_keypair_01" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair_01" {
  key_name   = format("%s%s%s%s", var.customer_code, "akp", var.environment_code, "ec201")
  public_key = tls_private_key.ec2_keypair_01.public_key_openssh
}

resource "aws_secretsmanager_secret" "ec2_keypair_01" {
  name                    = format("%s%s%s%s", var.customer_code, "sms", var.environment_code, "ec201")
  description             = "Amazon EC2 private key"
  recovery_window_in_days = 0

  tags = {
    Name        = format("%s%s%s%s", var.customer_code, "sms", var.environment_code, "ec201")
    resourcetype = "security"
    codeblock   = "codeblock06"
  }
}

##CORRUPTED##
##CORRUPTED##
##CORRUPTED##
##CORRUPTED##

