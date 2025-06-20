resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
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
# create subnets

resource "aws_subnet" "frontend_subnets" {
  count       = length(var.frontendServers)
  vpc_id      = aws_vpc.vpc.id
  cidr_block  = var.frontendServers[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-frontend-${count.index+1}"
  }
}
# resource "aws_subnet" "backend_subnets" {
#   count       = length(var.backendServers)
#   vpc_id      = aws_vpc.vpc.id
#   cidr_block  = var.backendServers[count.index]
#   availability_zone = var.availability_zone[count.index]
#   tags = {
#     Name = "${var.env}-backend-${count.index+1}"
#   }
# }
# resource "aws_subnet" "db_subnets" {
#   count       = length(var.dbServers)
#   vpc_id      = aws_vpc.vpc.id
#   cidr_block  = var.dbServers[count.index]
#   availability_zone = var.availability_zone[count.index]
#   tags = {
#     Name = "${var.env}-db-${count.index+1}"
#   }
# }
