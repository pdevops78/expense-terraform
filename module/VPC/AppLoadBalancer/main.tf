// create VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}
// create peer connection between default VPC and custom VPC
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept   = true
  tags = {
  Name = "${var.env}-peer"
  }
}

# create frontend subnets
resource "aws_subnet" "frontend_subnets" {
  count       = length(var.frontendServers)
  vpc_id      = aws_vpc.vpc.id
  cidr_block  = var.frontendServers[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-frontend-${count.index+1}"
  }
}

# create Frontend route table
resource "aws_route_table" "frontend" {
  count   = length(var.frontendServers)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-frontend-route-${count.index+1}"
      }
  }

#  Add Routes for for Frontend route table
resource "aws_route" "frontend_route" {
  count                     = length(var.frontendServers)
  route_table_id            = aws_route_table.frontend[count.index].id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
 }

 #  associate subnets with route table id
 resource "aws_route_table_association" "frontend" {
   count          = length(var.frontendServers)
   subnet_id      = aws_subnet.frontend_subnets[count.index].id
   route_table_id = aws_route_table.frontend[count.index].id
 }

 #  add destination vpc cidr block to default route table id
 resource "aws_route" "default_edit_route" {
     route_table_id            = var.default_vpc_route_table_id
     destination_cidr_block    = var.vpc_cidr_block
     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
 }
