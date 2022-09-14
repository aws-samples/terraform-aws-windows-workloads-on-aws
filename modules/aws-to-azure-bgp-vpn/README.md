# AWS to Azure HA BGP VPN
It typically takes 25 - 35 minutes to run in total.  
It will deploy a VPN Gateway3 on Azure as AWS is limited to 1.25Gb so the Azure side is also at 1.25Gb 

## Providers
- hashicorp/aws | version = ">=4.29.0"
- hashicorp/azure | version = ">=3.21.1"

## Variables description
**Do NOT** change the bgp routing peers as these are predefined
- **common_tags (map(any))**: AWS to Azure High Availability BGP VPN
- **aws_location (string)**: AWS Region
- **aws_location_prefix (string)**: Name for Created Resources
- **aws_vpn_bgp_asn (number)**: AWS BGP ASN
- **aws_vpn_bgp_peering_cidr_1 (string)**: AWS VPN BGP CIDR Peer
- **aws_vpn_bgp_peering_cidr_2 (string)**: AWS VPN BGP CIDR Peer
- **aws_vpn_bgp_peering_cidr_3 (string)**: AWS VPN BGP CIDR Peer
- **aws_vpn_bgp_peering_cidr_4 (string)**: AWS VPN BGP CIDR Peer
- **aws_vpn_bgp_peering_address_1 (string)**: AWS VPN BGP Peer IP Address
- **aws_vpn_bgp_peering_address_2 (string)**: AWS VPN BGP Peer IP Address
- **aws_vpn_bgp_peering_address_3 (string)**: AWS VPN BGP Peer IP Address
- **aws_vpn_bgp_peering_address_4 (string)**: AWS VPN BGP Peer IP Address
- **azure_location (string)**: Azure Region
- **azure_location_prefix (string)**: Add EUS for naming convention on Resources
- **azure_vnet_address_prefix (string)**: Virtual Network
- **azure_vnet_subnet_prefix_1 (string)**: Default Subnet
- **azure_vnet_subnet_prefix_2 (string)**: Gateway Subnet
- **azure_vpn_bgp_asn (number)**: Azure BGP ASN
- **azure_vpn_bgp_peering_cidr_1 (string)**: Azure VPN BGP CIDR Peer
- **azure_vpn_bgp_peering_cidr_2 (string)**: Azure VPN BGP CIDR Peer
- **azure_vpn_bgp_peering_cidr_3 (string)**: Azure VPN BGP CIDR Peer
- **azure_vpn_bgp_peering_cidr_4 (string)**: Azure VPN BGP CIDR Peer
- **azure_vpn_bgp_peering_address_1 (string)**: Azure VPN BGP Peer IP Address
- **azure_vpn_bgp_peering_address_2 (string)**: Azure VPN BGP Peer IP Address
- **azure_vpn_bgp_peering_address_3 (string)**: Azure VPN BGP Peer IP Address
- **azure_vpn_bgp_peering_address_4 (string)**: Azure VPN BGP Peer IP Address

## Usage
```hcl
module "aws-to-azure-bgp-vpn" {
  source = "aws-samples/windows-workloads-on-aws/aws//modules/aws-to-azure-bgp-vpn"

  aws_location   = "us-east-1"
  azure_location = "eastus"
}
```

## Setup Account
In Azure - create an App  Registration with a Secret - additional information in this
[article](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform)

These Values are obtained from the Azure App Registration
- ARM_CLIENT_SECRET
- ARM_CLIENT_ID
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID
Grant the App Registration the Subscription - Owner Role