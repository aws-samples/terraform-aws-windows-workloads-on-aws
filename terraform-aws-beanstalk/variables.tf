variable "vpc_id" {
  type        = string
  description = "VPC ID where the environment will be deployed"
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets where the application will be deployed"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets where the ALB will be deployed"
}

variable "beanstalk_net_framework_application_name" {
  type        = string
  description = "Beanstalk application name"
}

variable "beanstalk_net_framework_application_description" {
  type        = string
  description = "Beanstalk application description"
}

variable "beanstalk_net_framework_environment_name" {
  type        = string
  description = "Beanstalk environment name"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Sets EC2 instance type (default = t3.medium)"
}

variable "acm_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN to enable HTTPS"
}

variable "asg_min_instances" {
  type        = number
  default     = 1
  description = "Minimum number of instances to be addressed via ASG (default = 1)"
}

variable "asg_max_instances" {
  type        = number
  default     = 2
  description = "Maximum number of instances to be addressed via ASG (default = 2)"
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "key_name" {
  type        = string
  description = "key pair to securely log into the EC2 instances"
}