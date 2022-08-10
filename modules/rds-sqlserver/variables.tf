## Security Group
variable "rdssql_db_subnet_group_name" {
  type    = string
  default = "rdssql_db_subnet_group"
}


variable "rdssql_ingress_name" {
  type        = string
  description = "Security Group name"
  default     = "Amazon RDS for SQL Server - Security Group"
}

variable "rdssql_ingress_ports" {
  type        = list(number)
  description = "List of ports opened from Private Subnets CIDR to RDS SQL Instance"
  default     = [1433]
}

## Iam Roles for Domain join

variable "ManagedPolicy" {
  type    = list(any)
  default = ["arn:aws:iam::aws:policy/service-role/AmazonRDSDirectoryServiceAccess"]
}

## Amazon RDS for SQL Server

variable "rdssql_engine" {
  type        = list(any)
  description = "SQL Server Version"
  default     = ["sqlserver-ex", "sqlserver-web", "sqlserver-se", "sqlserver-ee"]
}

variable "rdssql_engine_version" {
  type        = list
  description = "15.00 = SQL Server 2019 / 14.00 = SQL Server 2017 / 13.00 = SQL Server 2016 / 12.00 = SQL Server 2014"
  default     = ["15.00", "14.00", "13.00", "12.00"]
}

variable "rdssql_password" {
  description = "RDS Admin password"
  type        = string
  default = "MyStrongPa$$w0rd"
  sensitive   = true
  ## Terraform _ Sensitive Variables = https://learn.hashicorp.com/tutorials/terraform/sensitive_variables
}

variable "time_zone" {
  description = "Database timezone"
  type        = string
  default     = "GMT Standard Time"
}

variable "sql_collation" {
  description = "SQL Server Collation"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "backup_windows_retention_maintenance" {
  description = "Backup window time, desired retention in days, maitenance windows"
  type        = list(any)
  default     = ["03:00-06:00", "35", "Mon:00:00-Mon:03:00"]
}

variable "rds_db_instance_class" {
  description = "Amazon RDS DB Instance class"
  type        = string
  default     = "db.t3.medium"
  # Instance type: https://aws.amazon.com/rds/sqlserver/instance_types/
}

variable "storage_allocation" {
  description = "Allocated storage Gb, Max allocated storage Gb"
  type        = list(any)
  default     = ["20", "100"]
}

variable "user_name" {
  description = "SQL Server Admin username"
  type        = string
  default     = "admin_mssql"
}