# AWS App Runner

Terraform module which deploys a sample application into AWS App Runner.

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description
- **apprunner_service_name (string)**: Name of the AWS App Runner service
- **image_port (string)**: Port that the application listens to in the container
- **image_repository (string)**: Image repository
- **image_tag (string)**: Image tag
- **repository_type (string)**: The type of the image repository. Valid values: ECR, ECR_PUBLIC.


## Usage

```hcl
module "app-runner" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/app-runner"

  apprunner_service_name = "apprunner-service"
  image_port             = "80"
  image_repository       = "public.ecr.aws/aws-containers/hello-app-runner"
  image_tag              = "latest"
  repository_type        = "ECR_PUBLIC"
}
```
## Outputs

- **application_url**: URL to the AWS App Runner application 