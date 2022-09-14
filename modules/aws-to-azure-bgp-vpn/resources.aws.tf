// AWS Cloud Resources
// Deploy Route Table
resource "aws_vpn_gateway_route_propagation" "main" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = data.aws_vpc.main.main_route_table_id
}

// Deploy VPN Gateway
resource "aws_vpn_gateway" "main" {
  vpc_id = data.aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.aws_location_prefix}-VPNGWY"
  })
}

// Deploy Customer Gateways
resource "aws_customer_gateway" "main_1" {
  ip_address = data.azurerm_public_ip.main_1.ip_address
  bgp_asn    = var.azure_vpn_bgp_asn
  type       = "ipsec.1"

  tags = merge(var.common_tags, {
    Name = "${var.aws_location_prefix}-CGW"
  })

  lifecycle {
    ignore_changes = [ip_address]
  }

  depends_on = [
    data.azurerm_public_ip.main_1
  ]
}
resource "aws_customer_gateway" "main_2" {
  ip_address = data.azurerm_public_ip.main_2.ip_address
  bgp_asn    = var.azure_vpn_bgp_asn
  type       = "ipsec.1"

  //tags = var.common_tags
  tags = merge(var.common_tags, {
    Name = "${var.aws_location_prefix}-CGW"
  })

  lifecycle {
    ignore_changes = [ip_address]
  }

  depends_on = [
    data.azurerm_public_ip.main_2
  ]
}

// Create VPN Connections
resource "aws_vpn_connection" "main_1" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main_1.id

  type                = "ipsec.1"
  tunnel1_inside_cidr = var.aws_vpn_bgp_peering_cidr_1
  tunnel2_inside_cidr = var.aws_vpn_bgp_peering_cidr_2

  //tags = var.common_tags
  tags = merge(var.common_tags, {
    Name = "${var.aws_location_prefix}-S2SVPN"
  })
}
resource "aws_vpn_connection" "main_2" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.main_2.id

  type                = "ipsec.1"
  tunnel1_inside_cidr = var.aws_vpn_bgp_peering_cidr_3
  tunnel2_inside_cidr = var.aws_vpn_bgp_peering_cidr_4

  //tags = var.common_tags
  tags = merge(var.common_tags, {
    Name = "${var.aws_location_prefix}-S2SVPN"
  })
}