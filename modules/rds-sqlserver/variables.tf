## Security Group
variable "rdssql_db_subnet_group_name" {
  type        = string
  default     = "rdssql_db_subnet_group"
  description = "Name for the DB subnet group"
}


variable "rdssql_ingress_name" {
  type        = string
  default     = "Amazon RDS for SQL Server - Security Group"
  description = "Security Group name"
}

variable "rdssql_ingress_ports" {
  type        = list(number)
  default     = [1433]
  description = "List of ports opened from Private Subnets CIDR to RDS SQL Instance"
}

## Iam Roles for Domain join

variable "ManagedPolicy" {
  type        = list(any)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"]
  description = "Managed policy for making calls to your directory"
}

## Amazon RDS for SQL Server

variable "rdssql_engine" {
  type        = list(any)
  default     = ["sqlserver-ex", "sqlserver-web", "sqlserver-se", "sqlserver-ee"]
  description = "SQL Server Version"
}

variable "rdssql_engine_version" {
  type        = list(any)
  default     = ["15.00", "14.00", "13.00", "12.00"]
  description = "15.00 = SQL Server 2019 / 14.00 = SQL Server 2017 / 13.00 = SQL Server 2016 / 12.00 = SQL Server 2014"
}

variable "rdssql_password" {
  type        = string
  default     = "MyStrongPa$$w0rd"
  description = "RDS Admin password"
  sensitive   = true
  ## Terraform _ Sensitive Variables = https://learn.hashicorp.com/tutorials/terraform/sensitive_variables
}

variable "time_zone" {
  type        = string
  default     = "GMT Standard Time"
  description = "Database timezone"
}

variable "sql_collation" {
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
  description = "SQL Server Collation"
}

variable "backup_windows_retention_maintenance" {
  type        = list(any)
  default     = ["03:00-06:00", "35", "Mon:00:00-Mon:03:00"]
  description = "Backup window time, desired retention in days, maitenance windows"
}

variable "rds_db_instance_class" {
  type        = string
  default     = "db.t3.medium"
  description = "Amazon RDS DB Instance class"
  # Instance type: https://aws.amazon.com/rds/sqlserver/instance_types/
}

variable "storage_allocation" {
  type        = list(any)
  default     = ["20", "100"]
  description = "Allocated storage Gb, Max allocated storage Gb"
}

variable "user_name" {
  type        = string
  default     = "admin_mssql"
  description = "SQL Server Admin username"
}