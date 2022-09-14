// Create Azure Resource Group
// Replace the name inside the Quotes with the name you prefer for the Resource Group
resource "azurerm_resource_group" "main" {
  name     = "AzureToAWS-BGPVpn-rg"
  location = var.azure_location

  tags = var.common_tags
}

// Deploy Azure Virtual Network - vNet
resource "azurerm_virtual_network" "main" {
  name                = "${var.azure_location_prefix}-VN0"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  address_space = [var.azure_vnet_address_prefix]

  tags = var.common_tags
}

// Deploy two Subnets
resource "azurerm_subnet" "main_1" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [var.azure_vnet_subnet_prefix_1]
}
resource "azurerm_subnet" "main_2" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name

  address_prefixes = [var.azure_vnet_subnet_prefix_2]
}

// Deploy Network Security Groups
resource "azurerm_network_security_group" "main" {
  name                = "${var.azure_location_prefix}-NSG0"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.common_tags
}
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main_1.id
  network_security_group_id = azurerm_network_security_group.main.id
}

// Deploy Azure Public IPs
resource "azurerm_public_ip" "main_1" {
  name                = "${var.azure_location_prefix}-PIP0"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Dynamic"

  tags = var.common_tags
}
resource "azurerm_public_ip" "main_2" {
  name                = "${var.azure_location_prefix}-PIP1"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  allocation_method = "Dynamic"

  tags = var.common_tags
}

// Deploy Azure VPN Gateway
// List of SKU's in Azure and expected throughput 
// On the AWS side - VPN is 1.25GB so larger VPN Gateways on Azure won't improve performance
// List of Gateways - https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways#benchmark

resource "azurerm_virtual_network_gateway" "main" {
  name                = "${var.azure_location_prefix}-VNG0"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  type          = "Vpn"
  vpn_type      = "RouteBased"
  active_active = true
  enable_bgp    = true
  sku           = "VpnGw3"
  generation    = "Generation1"


  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.main_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.main_2.id
  }
  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.main_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.main_2.id
  }

  bgp_settings {
    asn = var.azure_vpn_bgp_asn
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig1"
      apipa_addresses = [
        var.azure_vpn_bgp_peering_address_1,
        var.azure_vpn_bgp_peering_address_2,
      ]
    }
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig2"
      apipa_addresses = [
        var.azure_vpn_bgp_peering_address_3,
        var.azure_vpn_bgp_peering_address_4,
      ]
    }
  }

  tags = var.common_tags
}

// Azure Cloud Resources
// Deploy Local Gateway
resource "azurerm_local_network_gateway" "main_1" {
  name                = "${var.azure_location_prefix}-LNG0"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  gateway_address = aws_vpn_connection.main_1.tunnel1_address
  bgp_settings {
    asn                 = var.aws_vpn_bgp_asn
    bgp_peering_address = var.aws_vpn_bgp_peering_address_1
  }

  tags = var.common_tags
}
resource "azurerm_local_network_gateway" "main_2" {
  name                = "${var.azure_location_prefix}-LNG1"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  gateway_address = aws_vpn_connection.main_1.tunnel2_address
  bgp_settings {
    asn                 = var.aws_vpn_bgp_asn
    bgp_peering_address = var.aws_vpn_bgp_peering_address_2
  }

  tags = var.common_tags
}
resource "azurerm_local_network_gateway" "main_3" {
  name                = "${var.azure_location_prefix}-LNG2"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  gateway_address = aws_vpn_connection.main_2.tunnel1_address
  bgp_settings {
    asn                 = var.aws_vpn_bgp_asn
    bgp_peering_address = var.aws_vpn_bgp_peering_address_3
  }

  tags = var.common_tags
}
resource "azurerm_local_network_gateway" "main_4" {
  name                = "${var.azure_location_prefix}-LNG3"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  gateway_address = aws_vpn_connection.main_2.tunnel2_address
  bgp_settings {
    asn                 = var.aws_vpn_bgp_asn
    bgp_peering_address = var.aws_vpn_bgp_peering_address_4
  }

  tags = var.common_tags
}

// Create Connections
resource "azurerm_virtual_network_gateway_connection" "main_1" {
  name                = "${var.azure_location_prefix}-CN0"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.main_1.id
  shared_key                 = aws_vpn_connection.main_1.tunnel1_preshared_key
  enable_bgp                 = true

  tags = var.common_tags
}
resource "azurerm_virtual_network_gateway_connection" "main_2" {
  name                = "${var.azure_location_prefix}-CN1"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.main_2.id
  shared_key                 = aws_vpn_connection.main_1.tunnel2_preshared_key
  enable_bgp                 = true

  tags = var.common_tags
}
resource "azurerm_virtual_network_gateway_connection" "main_3" {
  name                = "${var.azure_location_prefix}-CN2"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.main_3.id
  shared_key                 = aws_vpn_connection.main_2.tunnel1_preshared_key
  enable_bgp                 = true

  tags = var.common_tags
}
resource "azurerm_virtual_network_gateway_connection" "main_4" {
  name                = "${var.azure_location_prefix}-CN3"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.main.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.main_4.id
  shared_key                 = aws_vpn_connection.main_2.tunnel2_preshared_key
  enable_bgp                 = true

  tags = var.common_tags
}