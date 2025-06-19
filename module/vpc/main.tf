resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = "${var.env}-subnet"
  }
}

resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept   = true
  tags = {
  Name = "${var.env}-peer"
  }
}

# resource "aws_route" "main_edit_route" {
#   route_table_id            = var.vpc_route_table_id
#   destination_cidr_block    = var.default_vpc_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }
#
# resource "aws_route" "default_edit_route" {
#   route_table_id            = var.default_vpc_route_table_id
#   destination_cidr_block    = var.vpc_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
# }
