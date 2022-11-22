# EC2 Windows Server with docker host in EC2 Linux

Terraform module which deploys an EC2 Windows instance and an EC2 Linux Docker host. Whenever a Docker command is issued on the Windows host, the Linux host will respond to the requests, making it all transparent to the user and allowing Linux Docker support on the Windows instance.

For security reasons, all instances will be located in private subnets. To access the instances, please use Fleet Manager for allowing secure communication without having to open ports. 

Note that you will need to provide key pair names for both the Windows and Linux hosts. You can create a key pair under EC2 >> Network & Security >> Key Pairs.

## Providers

- hashicorp/aws | version = "~> 4.0"

## Variables description
- **windows_key_pair (string)**: key pair used to connect to Windows EC2 instance
- **docker_host_key_pair (string)**: key pair used to connect to docker EC2 instance running Docker server
- **docker_host_port (number)**: Docker engine port
- **docker_host_instance_type (string)**: Docker EC2 instance type


## Usage

```hcl
module "ec2-windows-docker-host-linux" {
  source = "aws-samples/windows-workloads-on-aws/aws//modules/ec2-windows-docker-host-linux"

  windows_key_pair          = "test_kp"
  docker_host_key_pair      = "test_kp"
  docker_host_port          = 2375
  docker_host_instance_type = "m5.large"
}
```
## Outputs

- **application_url**: URL to the AWS App Runner application 