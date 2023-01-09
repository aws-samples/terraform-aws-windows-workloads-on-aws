# Create VPC
resource "aws_vpc" "vpc_01" {
  cidr_block       = format("%s.0.0/16", var.vpc_cidr)
  instance_tenancy = "default"
  
  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "vpc", var.EnvironmentCode, "01")
    resourcetype = "network"
    codeblock    = "existing_resources"
  }
}

# Create Private Subnets 03
resource "aws_subnet" "priv_subnet_03" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.5.0/24", var.vpc_cidr)
  availability_zone = var.az_01

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "sbn", "pv", var.EnvironmentCode, "03")
    resourcetype = "network"
    codeblock    = "existing_resources"
  }
}

# Create Private Subnets 04
resource "aws_subnet" "priv_subnet_04" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.6.0/24", var.vpc_cidr)
  availability_zone = var.az_02

  tags = {
    Name         = format("%s%s%s%s%s", var.CustomerCode, "sbn", "pv", var.EnvironmentCode, "04")
    resourcetype = "network"
    codeblock    = "existing_resources"
  }
}

# Create Data Security Group
resource "aws_security_group" "dat01" {
  name        = "pdoscgpddat01"
  description = "data security group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name      = format("%s%s%s%s", var.CustomerCode, "scg", var.EnvironmentCode, "dat01")
    rtype     = "security"
    codeblock = "existing_resources"
  }
}
# Create Microsoft Managed Active Directory Secrets Manager resources and import pre-created secrets
resource "aws_secretsmanager_secret" "mmad01" {
  name                    = format("%s%s%s%s", var.CustomerCode, "sms", var.EnvironmentCode, "mmad01")
  description             = "Microsoft Managed AD domain administrator credentials"
  recovery_window_in_days = 0

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "sms", var.EnvironmentCode, "mmad01")
    resourcetype = "security"
    codeblock    = "existing_resources"
  }
}

data "aws_secretsmanager_secret" "mmad01" {
  arn = aws_secretsmanager_secret.mmad01.arn
}

data "aws_secretsmanager_secret_version" "mmad01" {
  secret_id = data.aws_secretsmanager_secret.mmad01.id
}

# Create Microsoft Managed Active Directory
resource "aws_directory_service_directory" "mmad01" {
  name     = "capcom.pdo.com"
  
  password = jsondecode(data.aws_secretsmanager_secret_version.mmad01.secret_string)["password"]
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id     = aws_vpc.vpc_01.id
    subnet_ids = [aws_subnet.priv_subnet_03.id, aws_subnet.priv_subnet_04.id]
  }

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "mmad", var.EnvironmentCode, "01")
    resourcetype = "identity"
    codeblock    = "existing_resources"
  }
  
  lifecycle {
    ignore_changes = [password]
  }
}

# Create IAM role for Amazon RDS for SQL Server
data "aws_iam_policy_document" "rdsassumerole" {
  statement {
    sid = "AssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rdsadauth" {
  name                  = format("%s%s%s%s", var.CustomerCode, "iar", var.EnvironmentCode, "rdsauth01")
  description           = "Role used by RDS for Active Directory authentication and authorization"
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.rdsassumerole.json

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "iar", var.EnvironmentCode, "rdsauth01")
    resourcetype = "identity"
    codeblock    = "existing_resources"
  }
  
    lifecycle {
    ignore_changes = [tags,tags_all]
  }
}

resource "aws_iam_role_policy_attachment" "rdsdirectoryservices" {
  role       = aws_iam_role.rdsadauth.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"
}

# Create Amazon RDS for SQL Server Secrets Manager resources and import pre-created secrets
resource "aws_secretsmanager_secret" "rdsmssql01" {
  name                    = format("%s%s%s%s", var.CustomerCode, "sms", var.EnvironmentCode, "rds01")
  description             = "RDS for SQL Server credentials"
  recovery_window_in_days = 0

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "sms", var.EnvironmentCode, "02")
    resourcetype = "security"
    codeblock    = "existing_resources"
  }
}

data "aws_secretsmanager_secret" "rdsmssql01" {
  arn = aws_secretsmanager_secret.rdsmssql01.arn
}

data "aws_secretsmanager_secret_version" "rdsmssql01" {
  secret_id = data.aws_secretsmanager_secret.rdsmssql01.id
}

# Create DB Subnet Group for Amazon RDS for SQL Server
resource "aws_db_subnet_group" "rdsmssql01" {
  name        = format("%s%s%s%s", var.CustomerCode, "sbg", var.EnvironmentCode, "rdsmssql01")
  description = "DB Subnet group used by RDS for SQL Server"
  subnet_ids  = [aws_subnet.priv_subnet_03.id, aws_subnet.priv_subnet_04.id]

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "sbg", var.EnvironmentCode, "rdsmssql01")
    resourcetype = "network"
    codeblock    = "existing_resources"
  }
}

# Create Amazon RDS for SQL Server
resource "aws_db_instance" "rdsmssql01" {

  engine                                = "sqlserver-ee"
  engine_version                        = "15.00.4236.7.v1"
  license_model                         = "license-included"
  instance_class                        = "db.t3.xlarge"
  character_set_name                    = "SQL_Latin1_General_CP1_CI_AS"
  storage_type                          = "gp2"
  allocated_storage                     = 20
  max_allocated_storage                 = 50
  storage_encrypted                     = true
  apply_immediately                     = true
  identifier                            = format("%s%s", var.CustomerCode, "mssql01")
  username                              = "admin"
  password                              = jsondecode(data.aws_secretsmanager_secret_version.rdsmssql01.secret_string)["password"]
  port                                  = 1433
  domain                                = aws_directory_service_directory.mmad01.id
  domain_iam_role_name                  = aws_iam_role.rdsadauth.name
  multi_az                              = true
  vpc_security_group_ids                = [aws_security_group.dat01.id]   ##CORRUPT## 
  db_subnet_group_name                  = aws_db_subnet_group.rdsmssql01.name
  backup_retention_period               = 1
  delete_automated_backups              = true
  skip_final_snapshot                   = true
  deletion_protection                   = false
  copy_tags_to_snapshot                 = false
  publicly_accessible                   = false
  performance_insights_enabled          = true
  auto_minor_version_upgrade            = true
  enabled_cloudwatch_logs_exports       = ["error"]

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "rds", var.EnvironmentCode, "mssql01")
    resourcetype = "database"
    codeblock    = "existing_resources"
  }
  
  lifecycle {
    ignore_changes = [password]
  }
}

# Create Amazon FSx for Windows Server
resource "aws_fsx_windows_file_system" "mmad" {
  active_directory_id               = aws_directory_service_directory.mmad01.id
  aliases                           = ["fsx.capcom.pdo.com"]
  storage_capacity                  = 32
  storage_type                      = "SSD"
  subnet_ids                        = [aws_subnet.priv_subnet_03.id]
  throughput_capacity               = 16
  deployment_type                   = "SINGLE_AZ_2"
  automatic_backup_retention_days   = 0
  copy_tags_to_backups              = false
  skip_final_backup                 = true
  daily_automatic_backup_start_time = "01:00"
  weekly_maintenance_start_time     = "4:16:30"
  security_group_ids                = [aws_security_group.dat01.id]

  tags = {
    Name         = format("%s%s%s%s", var.CustomerCode, "fsx", var.EnvironmentCode, "mmadsingaz")
    resourcetype = "storage"
    codeblock    = "existing_resources"
  }
  
  lifecycle {
    ignore_changes = [security_group_ids]
  }
  

}