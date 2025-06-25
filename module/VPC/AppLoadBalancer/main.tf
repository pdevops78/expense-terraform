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
