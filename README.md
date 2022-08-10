## AWS Terraform Blueprint: Windows Workloads

The AWS Terraform Blueprint: Windows Workloads is a project born due to the lack of Terraform blueprints for Windows on AWS. A group of AWS Specialist Solution Architects on Windows Workloads at AWS developed these blueprints. You can use them as samples to build your own Terraform templates or deploy test environments.

We were inclined to simplicity, and our code is easy to read, being you new or an expert on Terraform. 

## How to use

You can use a VPC module to deploy a fully functional VPC with private/public subnets, internet gateway, nat gateway, and proper routing setup. Once you deploy this module, all other modules can be deployed on top of that. This is only required if you are starting with Terraform; otherwise, you can customize it as needed.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.