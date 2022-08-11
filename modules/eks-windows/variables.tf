variable "eks_cluster_name" {
  type        = string
  default     = "eks-windows"
  description = "Namne of the EKS cluster"
}

variable "endpoint_private_access" {
  type        = bool
  default     = true
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
}

variable "endpoint_public_access" {
  type        = bool
  default     = false
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
}

variable "public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
}


variable "enabled_cluster_log_types" {
  type        = list(string)
  default     = []
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
}

variable "cluster_log_retention_period" {
  type        = number
  default     = 0
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  default     = true
  description = "Set to `true` to enable Cluster Encryption Configuration"
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  default     = ""
  description = "KMS Key ID to use for cluster encryption config"
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  default     = true
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  default     = null
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
}

variable "cluster_encryption_config_resources" {
  type        = list(any)
  default     = ["secrets"]
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
}

variable "eks_cluster_version" {
  type        = string
  default     = "1.22"
  description = "Version for the EKS cluster"
}

variable "launch_template_name" {
  type        = string
  default     = "eks-windows-lt"
  description = "Name for the launch template"
}

variable "ec2_instance_types" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type"
}

variable "eks_windows_workernode_instance_profile_name" {
  type        = string
  default     = "eks_windows_workernode_instance_profile"
  description = "Worker node instance profile name"
}

variable "alb_ingress_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "List of ports opened from Internet to ALB"
}

variable "container_instances_ingress_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "List of ports opened from ALB to Container Instances"
}

variable "kubelet_extra_args" {
  type        = string
  default     = "--register-with-taints='os=windows:NoSchedule'"
  description = "This will make sure to taint your nodes at the boot time to avoid scheduling any existing resources in the new Windows worker nodes"
}

variable "map_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::0123456789:user/USER"
      username = "momarcio"
      groups   = ["system:masters"]
    },
  ]
  description = "Additional IAM users to add to the aws-auth configmap."
}