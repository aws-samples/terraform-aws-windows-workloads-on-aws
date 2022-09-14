variable "common_tags" {
  type = map(any)
  default = {
    "Provisioner" = "Terraform Cloud"
  }
  description = "AWS to Azure High Availability BGP VPN"
}

###
# AWS VARIABLES
###
variable "aws_location" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "aws_location_prefix" {
  type        = string
  default     = "USE1-AWStoAzureVPN"
  description = "Name for Created Resources"
}


variable "aws_vpn_bgp_asn" {
  type        = number
  default     = 64512
  description = "AWS BGP ASN"
}

variable "aws_vpn_bgp_peering_cidr_1" {
  type        = string
  default     = "169.254.21.0/30"
  description = "AWS VPN BGP CIDR Peer"
}

variable "aws_vpn_bgp_peering_cidr_2" {
  type        = string
  default     = "169.254.22.0/30"
  description = "AWS VPN BGP CIDR Peer"
}

variable "aws_vpn_bgp_peering_cidr_3" {
  type        = string
  default     = "169.254.21.4/30"
  description = "AWS VPN BGP CIDR Peer"
}

variable "aws_vpn_bgp_peering_cidr_4" {
  type        = string
  default     = "169.254.22.4/30"
  description = "AWS VPN BGP CIDR Peer"
}

variable "aws_vpn_bgp_peering_address_1" {
  type        = string
  default     = "169.254.21.1"
  description = "AWS VPN BGP Peer IP Address"
}

variable "aws_vpn_bgp_peering_address_2" {
  type        = string
  default     = "169.254.22.1"
  description = "AWS VPN BGP Peer IP Address"
}

variable "aws_vpn_bgp_peering_address_3" {
  type        = string
  default     = "169.254.21.5"
  description = "AWS VPN BGP Peer IP Address"
}

variable "aws_vpn_bgp_peering_address_4" {
  type        = string
  default     = "169.254.22.5"
  description = "AWS VPN BGP Peer IP Address"
}

###
# AZURE VARIABLES
###
variable "azure_location" {
  type        = string
  default     = "eastus"
  description = "Azure Region"
}

variable "azure_location_prefix" {
  type        = string
  default     = "EUS"
  description = "Add EUS for naming convention on Resources"
}

variable "azure_vnet_address_prefix" {
  type        = string
  default     = "172.31.0.0/16"
  description = "Virtual Network"
}

variable "azure_vnet_subnet_prefix_1" {
  type        = string
  default     = "172.31.0.0/24"
  description = "Default Subnet"
}

variable "azure_vnet_subnet_prefix_2" {
  type        = string
  default     = "172.31.254.0/24"
  description = "Gateway Subnet"
}

variable "azure_vpn_bgp_asn" {
  type        = number
  default     = 65515
  description = "Azure BGP ASN"
}

variable "azure_vpn_bgp_peering_cidr_1" {
  type        = string
  default     = "169.254.21.0/30"
  description = "Azure VPN BGP CIDR Peer"
}

variable "azure_vpn_bgp_peering_cidr_2" {
  type        = string
  default     = "169.254.22.0/30"
  description = "Azure VPN BGP CIDR Peer"
}

variable "azure_vpn_bgp_peering_cidr_3" {
  type        = string
  default     = "169.254.21.4/30"
  description = "Azure VPN BGP CIDR Peer"
}

variable "azure_vpn_bgp_peering_cidr_4" {
  type        = string
  default     = "169.254.22.4/30"
  description = "Azure VPN BGP CIDR Peer"
}

variable "azure_vpn_bgp_peering_address_1" {
  type        = string
  default     = "169.254.21.2"
  description = "Azure VPN BGP Peer IP Address"
}

variable "azure_vpn_bgp_peering_address_2" {
  type        = string
  default     = "169.254.22.2"
  description = "Azure VPN BGP Peer IP Address"
}

variable "azure_vpn_bgp_peering_address_3" {
  type        = string
  default     = "169.254.21.6"
  description = "Azure VPN BGP Peer IP Address"
}

variable "azure_vpn_bgp_peering_address_4" {
  type        = string
  default     = "169.254.22.6"
  description = "Azure VPN BGP Peer IP Address"
}
