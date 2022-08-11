# Amazon EKS for Windows containers

Terraform module which deploys an EKS cluster for Windows containers. 

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description
- **eks_cluster_name (string)**: Namne of the EKS cluster
- **endpoint_private_access (bool)**: Indicates whether or not the Amazon EKS private API server endpoint is enabled
- **endpoint_public_access (bool)**: Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true
- **public_access_cidrs (list(string))**: Indicates which CIDR blocks can access the Amazon EKS public API server endpoint when enabled. EKS defaults this to a list with 0.0.0.0/0.
- **enabled_cluster_log_types (list(string))**: A list of the desired control plane logging to enable. For more information, see https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html. Possible values [`api`, `audit`, `authenticator`, `controllerManager`, `scheduler`]
- **cluster_log_retention_period (number)**: Number of days to retain cluster logs. Requires `enabled_cluster_log_types` to be set. See https://docs.aws.amazon.com/en_us/eks/latest/userguide/control-plane-logs.html.
- **cluster_encryption_config_enabled (bool)**: Set to `true` to enable Cluster Encryption Configuration
- **cluster_encryption_config_kms_key_id (string)**: KMS Key ID to use for cluster encryption config
- **cluster_encryption_config_kms_key_enable_key_rotation (bool)**: Cluster Encryption Config KMS Key Resource argument - enable kms key rotation
- **cluster_encryption_config_kms_key_deletion_window_in_days (number)**: Cluster Encryption Config KMS Key Resource argument - key deletion windows in days post destruction
- **cluster_encryption_config_kms_key_policy (string)**: Cluster Encryption Config KMS Key Resource argument - key policy
- **cluster_encryption_config_resources (list(any))**: Cluster Encryption Config Resources to encrypt, e.g. ['secrets']
- **eks_cluster_version (string)**: Version for the EKS cluster
- **launch_template_name (string)**: Name for the launch template
- **ec2_instance_types (string)**: EC2 instance type
- **eks_windows_workernode_instance_profile_name (string)**: Worker node instance profile name
- **alb_ingress_ports (list(number))**: List of ports opened from Internet to ALB
- **container_instances_ingress_ports (list(number))**: List of ports opened from ALB to Container Instances
- **kubelet_extra_args (string)**: This will make sure to taint your nodes at the boot time to avoid scheduling any existing resources in the new Windows worker nodes
- **map_users (list(object({})))**: Additional IAM users to add to the aws-auth configmap.


## Usage

```hcl
module "eks-windows" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/eks-windows"

  eks_cluster_name    = "eks-windows"
  eks_cluster_version = "1.22"
  ec2_instance_types  = "t3.medium"
}
```
## Outputs