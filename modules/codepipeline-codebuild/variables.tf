variable "github_path" {
  type        = string
  default     = "cbossie/tf-sample-app"
  description = "Path to github repository"
}

variable "github_url" {
  type        = string
  default     = "https://github.com/cbossie/tf-sample-app.git"
  description = "github url"
}

variable "codebuild_project_name" {
  type        = string
  default     = "modernization-build-project"
  description = "Name of the codebuild project"
}

variable "ecr_repository_name" {
  type        = string
  default     = "modernization-repo"
  description = "Name of the ECR repository"
}

variable "pipeline_name" {
  type        = string
  default     = "modernization-pipeline"
  description = "Name of the codebuild project"
}

variable "buildspec_path" {
  type        = string
  default     = "./buildspec.yml"
  description = "Path for the buildspec file"
}