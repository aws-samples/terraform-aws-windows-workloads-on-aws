variable "eks_cluster_name" {
  type    = string
  default = "eks-windows"
}

variable "endpoint_private_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false"
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true"
  default     = false
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0."
  default     = ["0.0.0.0/0"]
}


variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]"
  default     = []
}

variable "cluster_log_retention_period" {
  type        = number
  description = "Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html."
  default     = 0
}

variable "cluster_encryption_config_enabled" {
  type        = bool
  description = "Set to `true` to enable Cluster Encryption Configuration"
  default     = true
}

variable "cluster_encryption_config_kms_key_id" {
  type        = string
  description = "KMS Key ID to use for cluster encryption config"
  default     = ""
}

variable "cluster_encryption_config_kms_key_enable_key_rotation" {
  type        = bool
  description = "Cluster Encryption Config KMS Key Resource argument - enable kms key rotation"
  default     = true
}

variable "cluster_encryption_config_kms_key_deletion_window_in_days" {
  type        = number
  description = "Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction"
  default     = 10
}

variable "cluster_encryption_config_kms_key_policy" {
  type        = string
  description = "Cluster Encryption Config KMS Key Resource argument - key policy"
  default     = null
}

variable "cluster_encryption_config_resources" {
  type        = list(any)
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
  default     = ["secrets"]
}

variable "eks_cluster_version" {
  type    = string
  default = "1.22"
}

variable "launch_template_name" {
  type    = string
  default = "eks-windows-lt"
}

variable "ec2_instance_types" {
  type    = string
  default = "t3.medium"
}

variable "eks_windows_workernode_instance_profile_name" {
  type    = string
  default = "eks_windows_workernode_instance_profile"
}

variable "alb_ingress_ports" {
  type        = list(number)
  description = "List of ports opened from Internet to ALB"
  default     = [80, 443]
}

variable "container_instances_ingress_ports" {
  type        = list(number)
  description = "List of ports opened from ALB to Container Instances"
  default     = [80, 443]
}

variable "kubelet_extra_args" {
  description = "This will make sure to taint your nodes at the boot time to avoid scheduling any existing resources in the new Windows worker nodes"
  type        = string
  default     = "--register-with-taints='os=windows:NoSchedule'"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::629760017811:user/momarcio"
      username = "momarcio"
      groups   = ["system:masters"]
    },
  ]
}