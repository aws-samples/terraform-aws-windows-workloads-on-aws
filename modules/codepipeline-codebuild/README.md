# AWS Codepipeline and AWS Codebuild

Terraform module that deploys a pipeline that builds a container image from a .NET application in a GitHub repository and pushes the image to ECR.

NOTE: After deploying the pipeline for the first time, there's a manual action for GitHub changes to be pulled. Once deployed, go to CodePipeline and you will see an error in the Source stage. Click **Edit**, then click **Edit stage** in the Source stage and finally hit the edit icon in the Source action. You will see an info message that prompts you to **Finish creating the connection**. You'll need to follow the steps to create the GitHub connection, and finally you will see this message turning green stating **Ready to connect**. You can now go back to the pipeline and **Release change**.

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description
- **codebuild_project_name (string)**: Name of the codebuild project
- **ecr_repository_name (string)**: Name of the ECR repository
- **pipeline_name (string)**: Name of the codebuild project
- **github_path (string)**: Path to github repository
- **github_url (string)**: github url
- **buildspec_path (string)**: Path for the buildspec file


## Usage

```hcl
module "codepipeline-codebuild" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/codepipeline-codebuild"
  version = "1.0.2"

  codebuild_project_name = "modernization-build-project"
  ecr_repository_name    = "modernization-repo"
  pipeline_name          = "modernization-pipeline"
  github_path            = "cbossie/tf-sample-app"
  github_url             = "https://github.com/cbossie/tf-sample-app.git"
  buildspec_path         = "../codepipeline-codebuild/buildspec.yml"
}
```
## Outputs

- **application_url**: URL to the AWS App Runner application 