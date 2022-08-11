# Amazon RDS for SQL Server

Terraform module which creates and RDS instance for SQL Server.

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description
- **rdssql_db_subnet_group_name (string)**: Name for the DB subnet group
- **rdssql_ingress_name (string)**: Security Group name
- **rdssql_ingress_ports (list(number))**: List of ports opened from Private Subnets CIDR to RDS SQL Instance
- **ManagedPolicy (list(any))**: Managed policy for making calls to your directory
- **rdssql_engine (ist(any))**: SQL Server Version
- **rdssql_engine_version (list)**: 15.00 = SQL Server 2019 / 14.00 = SQL Server 2017 / 13.00 = SQL Server 2016 / 12.00 = SQL Server 2014
- **rdssql_password (string)**: RDS Admin password
- **time_zone (string)**: Database timezone
- **sql_collation (string)**: SQL Server Collation
- **backup_windows_retention_maintenance (list(any))**: Backup window time, desired retention in days, maitenance windows
- **rds_db_instance_class (string)**: Amazon RDS DB Instance class
- **storage_allocation (list(any))**: Allocated storage Gb, Max allocated storage Gb
- **user_name (string)**: SQL Server Admin username


## Usage

```hcl
module "rds-sqlserver" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/rds-sqlserver"
  version = "1.0.2"

  rds_db_instance_class = "db.t3.medium"
  user_name             = "admin_mssql"
}
```
## Outputs
