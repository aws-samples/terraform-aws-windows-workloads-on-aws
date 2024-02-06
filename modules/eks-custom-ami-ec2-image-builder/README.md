# EC2 Image Builder for EKS Custom Windows Optimized AMI

Terraform module which deploys an EC2 Image Builder pipeline that creates EKS custom Windows Optimized AMI

## Providers

- hashicorp/aws | version = "~> 5.0"

## Variables description
- **eks_cluster_version (string)**: Amazon EKS cluster version
- **region (string)**: AWS region to deploy the pipeline
- **image_recipe_name (string)**: EC2 Image Builder image recipe name
- **image_recipe_version (string)**: EC2 Image Builder image recipe name
- **component_name_image_cache (string)**: Image cache components that name
- **image_pipeline_timezone (string)**: Sets the pipeline timezone for recurring runnings
- **fast_launch_max_parallel_launches (string)**: Controls how many instances can be launched at a time for creating the pre-provisioned snapshots
- **snapshot_configuration_target_resource_count (string)**: The number of pre-provisioned snapshots to keep on hand for an AMI with faster launching enabled

## Usage

```hcl
module "ecs-windows" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/eks-custom-ami-ec2-image-builder"

}
```
