variable "windows_key_pair" {
  type        = string
  default     = "terraform_bootcamp"
  description = "key pair used to connect to Windows EC2 instance"
}

variable "docker_host_key_pair" {
  type        = string
  default     = "terraform_bootcamp"
  description = "key pair used to connect to docker EC2 instance running Docker server"
}


variable "docker_host_port" {
  type        = number
  default     = 2375
  description = "Docker engine port"
}

variable "docker_host_instance_type" {
  type        = string
  default     = "m5.large"
  description = "Docker EC2 instance type"
}