## AWS Terraform Blueprint: Windows Workloads

The AWS Terraform Blueprint: Windows Workloads is a project born due to the lack of Terraform blueprints for Windows on AWS. A group of AWS Specialist Solution Architects on Windows Workloads at AWS developed these blueprints. You can use them as samples to build your own Terraform templates or deploy test environments.

We were inclined to simplicity, and our code is easy to read, whether you are new to Terraform or an expert. 

## How to use
Navigate into the **modules** folder, where you can find each individual module that we have created. 


First of all, you can use a VPC module to deploy a fully functional VPC with private/public subnets, internet gateway, nat gateway, and proper routing setup. Once you deploy this module, all other modules can be deployed on top of that. This is only required if you are starting with Terraform; otherwise, you can customize it as needed.

You can choose between two options for using these modules:
- Downloading the modules and including them in your project
- Using them directly from the [Terraform registry](https://registry.terraform.io/modules/aws-samples/windows-workloads-on-aws/aws). From here, click the **submodules** banner and select the one you're interested in learning about. This will load all the information and instructions for using the module.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the [LICENSE](LICENSE.md) file.