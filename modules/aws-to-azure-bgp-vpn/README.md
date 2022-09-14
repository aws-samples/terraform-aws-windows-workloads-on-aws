# AWS to Azure HA BGP VPN
It typically takes 25 - 35 minutes to run in total.  
It will deploy a VPN Gateway3 on Azure as AWS is limited to 1.25Gb so the Azure side is also at 1.25Gb 

## Providers
- hashicorp/aws | version = ">=4.29.0"
- hashicorp/azure | version = ">=3.21.1"

## Setup Account
In Azure - create an App  Registration with a Secret - additional information in this
[article](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform)

These Values are obtained from the Azure App Registration
- ARM_CLIENT_SECRET
- ARM_CLIENT_ID
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID
Grant the App Registration the Subscription - Owner Role

## variables.tf
Update the deployment Region of AWS Resources
    - Change **'us-east-1'** to your AWS Region along with your preferred CIDR Ranges  
Update the deployment Region of Azure Resources 
    - Change **'eastus'** to your Azure Region along with your preferred CIDR Ranges

**Do NOT** change the bgp routing peers as these are predefined
    


