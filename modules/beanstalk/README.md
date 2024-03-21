# AWS Elastic Beanstalk .NET

Terraform module which manages AWS Elastic Beanstalk resources related to Windows Server 2022 (latest) with a sample ASP.NET application (_WebServer tier_), leveraging Application Load Balancer and Auto Scaling Group. What it manages:

- IAM resources (role and instance profile)
- Security groups
- Beanstalk application
- Beanstalk environment
- Application Load Balancer
- Auto Scaling group
- EC2 instances

## Providers

- hashicorp/aws | version = "~> 5.0"

## Variables description

- **region (string)**: AWS Region where the resources should be deployed (optional / default = us-east-1)
- **vpc_id (string)**: VPC ID where the environment will be deployed. If not set, Default VPC will be used (optional / default = null)
- **private_subnets (list(string))**: Private subnets where the application instances will be deployed. If not set, private subnets from Default VPC will be used based on tag:value format _Tier:Private_ (optional / default = null)
- **public_subnets (list(string))**: Public subnets where the Application Load Balancer will be deployed. If not set, public subnets from Default VPC will be used based on tag:value format _Tier:Public_ (optional / default = null)
- **beanstalk_net_windows_application_name (string)**: Beanstalk application name (required)
- **beanstalk_net_windows_application_description (string)**: Beanstalk application description (required)
- **beanstalk_net_windows_environment_name (string)**: Beanstalk environment name (required)
- **ec2_instance_type (string)**: EC2 instance type that is going to be deployed by Beanstalk (optional / default = t3.medium)
- **asg_min_instances (number)**: Minimum number of instances to be addressed via ASG (optional / default = 1)
- **asg_max_instances (number)**: Maximum number of instances to be addressed via ASG (optional / default = 2)
- **tags (map(any))**: Tags to be applied (recommended)
- **key_name (string)**: Key pair to securely log into the EC2 instances (required)
- **acm_arn (string)**: ACM certificate ARN - only required if HTTPS needs to be enabled - an _HTTP to HTTPS_ redirect rule will also be created at the Application Load Balancer (optional / default = null)

## Usage

```hcl
module "beanstalk" {
  source  = "aws-samples/windows-workloads-on-aws/aws//modules/beanstalk"

  vpc_id                                          = "vpc-1234567"
  private_subnets                                 = ["subnet-123456","subnet-654321"]
  public_subnets                                  = ["subnet-456789","subnet-987654"]
  beanstalk_net_framework_application_name        = "Application name"
  beanstalk_net_framework_application_description = "Application description"
  beanstalk_net_framework_environment_name        = "Development"
  ec2_instance_type                               = "t3.medium"
  acm_arn                                         = "arn:aws:acm:us-east-2:123456789:certificate/e12345abc-1122-ab123-0101-123456789"
  asg_min_instances                               = 2
  asg_max_instances                               = 4
  key_name                                        = "key01"

  tags = {
    tag1_name = "tag_value"
    tag2_name = "tag2_value"
  }
}
```
## Outputs

- **beanstalk_net_windows_uri**: The URL to the Application Load Balancer for the Environment
- **beanstalk_net_windows_cname**: Fully qualified DNS name for the Environment

## Notes

- [checkov scan](https://www.checkov.io/) may report [CKV2_AWS_5](https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-networking-policies/ensure-that-security-groups-are-attached-to-ec2-instances-or-elastic-network-interfaces-enis) issue, which validates if a security group is attached to EC2 instances or ENIs resources. This may fail because, in this module, the security group is attached to the [aws_elastic_beanstalk_environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_environment) resource, which is not evaluated by CKV2_AWS_5.
- [checkov scan](https://www.checkov.io/) may report [CKV2_AWS_312](https://docs.prismacloud.io/en/enterprise-edition/policy-reference/aws-policies/aws-general-policies/bc-aws-312) issue, which validates if the environment has enhanced reporting (_HealthStreamingEnabled_) option enabled on the _aws:elasticbeanstalk:healthreporting:system_ namespace. This may fail because this option is now related to the [_aws:elasticbeanstalk:cloudwatch:logs:health_ namespace](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-cloudwatchlogs-health).
- The Elastic Beanstalk API creates two default security groups: one for the Elastic Load Balancer (_awseb-e-xxxxxxxx-stack-AWSEBLoadBalancerSecurityGroup-YYYYYYYYYY_) and one for the EC2 Instances (_awseb-e-xxxxxxxx-stack-AWSEBSecurityGroup-YYYYYYYYYY_). To avoid affecting the default behavior, this module creates two additional security groups to address any tailored inbound and outbound rules needed for the environment. Related GitHub issues: [link1](https://github.com/aws/elastic-beanstalk-roadmap/issues/44) / [link2](https://github.com/hashicorp/terraform-provider-aws/issues/2002).