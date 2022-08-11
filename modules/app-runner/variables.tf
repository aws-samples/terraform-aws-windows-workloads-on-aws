variable "apprunner_service_name" {
  type        = string
  default     = "apprunner-service"
  description = "Name of the App Runner service"
}

variable "image_port" {
  type        = string
  default     = "80"
  description = "Port that the application listens to in the container"
}

variable "image_repository" {
  type        = string
  default     = "public.ecr.aws/aws-containers/hello-app-runner"
  description = "Image repository"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Image tag"
}

variable "repository_type" {
  type        = string
  default     = "ECR_PUBLIC"
  description = "The type of the image repository. Valid values: ECR, ECR_PUBLIC."
}