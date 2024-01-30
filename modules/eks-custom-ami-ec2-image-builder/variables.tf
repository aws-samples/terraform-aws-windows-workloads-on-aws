variable "eks_cluster_version" {
  type        = string
  default     = "1.29"
  description = "Version for the EKS cluster"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region to deploy the pipeline"
}

variable "image_recipe_name" {
  type        = string
  default     = "eks-custom-windows-ami"
  description = "Cache .NET Framework container images to accelerate Windows container startup time"
}

variable "image_recipe_version" {
  type        = string
  default     = "1.0.0"
  description = "Image Recipe version"
}


variable "component_name_image_cache" {
  type        = string
  default     = "containerdpull"
  description = "Cache .NET Framework container images to accelerate Windows container startup time"
}

variable "image_pipeline_timezone" {
  default     = "America/Los_Angeles"
  description = "Change timezone - IANA timezone format "
}

variable "fast_launch_max_parallel_launches" {
  type    = number
  default = 10
}

variable "snapshot_configuration_target_resource_count" {
  type    = number
  default = 10

}