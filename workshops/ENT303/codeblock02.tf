# Create Internet Gateway
resource ##CORRUPT## "internet_gateway_01" {
  vpc_id = aws_vpc.vpc_01.id

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "igw", var.environment_code, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"

  }

}

# Create Subnets
resource "aws_subnet" "pub_subnet_01" {
  ##CORRUPT##
  cidr_block        = format("%s.1.0/24", var.vpc_cidr)
  availability_zone = var.az_01

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "sbn", "pb", var.environment_code, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

}

resource "aws_subnet" "pub_subnet_02" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.2.0/24", var.vpc_cidr)
  availability_zone = var.az_02

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "sbn", "pb", var.environment_code, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

}

resource "aws_subnet" "priv_subnet_01" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.3.0/24", var.vpc_cidr)
  availability_zone = var.az_01

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "sbn", "pv", var.environment_code, "01")
    resourcetype = "network"
    codeblock    = "codeblock02r"
  }

}

resource "aws_subnet" "priv_subnet_02" {
  vpc_id            = aws_vpc.vpc_01.id
  cidr_block        = format("%s.4.0/24", var.vpc_cidr)
  availability_zone = var.az_02

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "sbn", "pv", var.environment_code, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

}

# Create NAT Gateway
resource "aws_eip" "eip_nat_01" {
  depends_on = [aws_internet_gateway.internet_gateway_01]
}

resource "aws_eip" "eip_nat_02" {
  depends_on = [aws_internet_gateway.internet_gateway_01]
}

resource "aws_nat_gateway" "nat_gateway_01" {
  allocation_id = aws_eip.eip_nat_01.id
  subnet_id     = aws_subnet.pub_subnet_01.id

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "ngw", var.environment_code, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

  depends_on = [aws_internet_gateway.internet_gateway_01]
}

resource "aws_nat_gateway" "nat_gateway_02" {
  ##CORRUPT##
  subnet_id     = aws_subnet.pub_subnet_02.id

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "ngw", var.environment_code, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }

  depends_on = [aws_internet_gateway.internet_gateway_01]
}

# Create Route Tables
resource "aws_route_table" "pub_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_01.id
  }

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "rtt", "pb", var.environment_code, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }
}

resource "aws_route_table_association" "pub_01" {
  subnet_id      = aws_subnet.pub_subnet_01.id
  route_table_id = aws_route_table.pub_01.id
}

resource "aws_route_table_association" "pub_02" {
  subnet_id      = aws_subnet.pub_subnet_02.id
  route_table_id = aws_route_table.pub_01.id
}

resource "aws_route_table" "priv_01" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_01.id

  }

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "rtt", "pv", var.environment_code, "01")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }
}

resource "aws_route_table" "priv_02" {
  vpc_id = aws_vpc.vpc_01.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_02.id
  }

  tags = {
    Name         = format("%s%s%s%s%s", var.customer_code, "rtt", "pv", var.environment_code, "02")
    resourcetype = "network"
    codeblock    = "codeblock02"
  }
}

resource "aws_route_table_association" "pv_01" {
  subnet_id      = aws_subnet.priv_subnet_01.id
  route_table_id = aws_route_table.priv_01.id
}

resource "aws_route_table_association" "pv_02" {
  subnet_id      = aws_subnet.priv_subnet_02.id
  route_table_id = aws_route_table.priv_01.id
}

resource "aws_route_table_association" "pv_03" {
  subnet_id      = aws_subnet.priv_subnet_03.id
  route_table_id = aws_route_table.priv_01.id
}

resource "aws_route_table_association" "pv_04" {
  subnet_id      = aws_subnet.priv_subnet_04.id
  route_table_id = aws_route_table.priv_01.id
}

# Security Groups
resource "aws_security_group" "web01" {
  name        = format("%s%s%s%s", var.customer_code, "scg", var.environment_code, "web01")
  description = "Web Security Group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description = "Web Inbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  ingress {
    description = "Web Inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Web Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "scg", var.environment_code, "web01")
    resourcetype = "security"
    codeblock    = "codeblock02"
  }
}

resource "aws_security_group" "app01" {
  name        = format("%s%s%s%s", var.customer_code, "scg", var.environment_code, "app01")
  description = " Application Security Group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "Application Inbound"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.web01.id]
    self            = true
  }

  egress {
    description = "Application Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "scg", var.environment_code, "app01")
    resourcetype = "security"
    codeblock    = "codeblock02"
  }
}

resource "aws_security_group" "dat01" {
  name        = format("%s%s%s%s", var.customer_code, "scg", var.environment_code, "dat01")
  description = "data security group"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "Data Inbound"
    from_port       = 1421
    to_port         = 1421
    protocol        = "tcp"
    security_groups = [aws_security_group.app01.id]
    self            = true
  }

  egress {
    description = "Data Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name         = format("%s%s%s%s", var.customer_code, "scg", var.environment_code, "dat01")
    resourcetype = "security"
    codeblock    = "codeblock02"
  }
}
