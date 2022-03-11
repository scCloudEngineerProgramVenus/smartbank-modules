resource "aws_route_table" "route_table" {

  vpc_id = var.vpc_id
  tags = {
    Name = var.name
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
}