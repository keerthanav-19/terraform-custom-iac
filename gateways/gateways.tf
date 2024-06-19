resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = var.nat_gateway_eip1
  subnet_id = var.subnet_public1
  tags = {
    Name = "${var.client}-nat_gateway1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = var.nat_gateway_eip2
  subnet_id = var.subnet_public2
  tags= {
    Name = "${var.client}-nat_gateway2"
  }
}
############PUBLIC###############
resource "aws_route_table" "rt_public" {
  vpc_id = var.vpc
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  tags= {
    Name = "${var.client}-internet_gateway"
  }
}

resource "aws_route_table_association" "rtb_public_1" {
  subnet_id      = var.subnet_public1
  route_table_id = aws_route_table.rt_public.id
}
resource "aws_route_table_association" "rtb_public_2" {
  subnet_id      = var.subnet_public2
  route_table_id = aws_route_table.rt_public.id
}
###############PRIVATE###############
resource "aws_route_table" "rt_private1" {
  vpc_id = var.vpc
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id
  }
  tags = {
    Name = "${var.client}-nat_gateway1"
  }
}

resource "aws_route_table" "rt_private2" {
  vpc_id = var.vpc
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2.id
  }
  tags = {
    Name = "${var.client}-nat_gateway2"
  }
}

resource "aws_route_table_association" "rtb_private_1" {
  subnet_id      = var.subnet_private1
  route_table_id = aws_route_table.rt_private1.id
}

resource "aws_route_table_association" "rtb_private_2" {
  subnet_id      = var.subnet_private2
  route_table_id = aws_route_table.rt_private2.id

}

