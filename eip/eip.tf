
resource "aws_eip" "nat_gateway_eip1" {
  vpc      = true
}

resource "aws_eip" "nat_gateway_eip2" {
  vpc      = true
}