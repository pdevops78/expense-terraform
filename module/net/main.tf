// create VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

# peer connection between default and custom vpc
resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept   = true
  tags = {
    Name = "${var.env}-peer"
  }
}
#  create  Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name ="${var.env}-ig"
  }
}
#  create eip
resource "aws_eip" "eip" {
  count = length(var.publicServers)
  tags = {
    Name = "${var.env}-eip-${count.index}"
  }
}

#  create a NAT gateway
resource "aws_nat_gateway" "nat" {
  count         = length(var.publicServers)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.env}-ig-${count.index}"
  }
}
# ******************************* frontend  ****************************************
//create frontend subnets / servers
resource "aws_subnet" "frontend_subnets" {
  count       = length(var.frontendServers)
  vpc_id      = aws_vpc.vpc.id
  cidr_block  = var.frontendServers[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-frontend-${count.index+1}"
  }
}

#  create Route table for frontend
resource "aws_route_table" "frontend" {
  count   = length(var.frontendServers)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-frontend-route-${count.index+1}"
  }
}

#  add default vpc cidr block to route_table
resource "aws_route" "frontend_route" {
  count                     = length(var.frontendServers)
  route_table_id            = aws_route_table.frontend[count.index].id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

#  associate frontend subnets with nat
resource "aws_route" "frontend_nat" {
  count                     = length(var.frontendServers)
  route_table_id            = aws_route_table.frontend[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat[count.index].id
}

#  associate subnets with route table id
resource "aws_route_table_association" "frontend" {
  count          = length(var.frontendServers)
  subnet_id      = aws_subnet.frontend_subnets[count.index].id
  route_table_id = aws_route_table.frontend[count.index].id
}

# ************************************ frontend end *************************************************

# ************************************** backend *****************************************************

#  create backend subnets / servers
resource "aws_subnet" "backend_subnets" {
  count       = length(var.backendServers)
  vpc_id      = aws_vpc.vpc.id
  cidr_block  = var.backendServers[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-backend-${count.index+1}"
  }
}
#
# # #  create Route table for backend
resource "aws_route_table" "backend" {
  count   = length(var.backendServers)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-backend-route-${count.index+1}"
  }
}
#  add default vpc cidr block to route_table
resource "aws_route" "backend_route" {
  count                     = length(var.backendServers)
  route_table_id            = aws_route_table.backend[count.index].id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
#
# #  associate backend subnets with nat
resource "aws_route" "backend_nat" {
  count                     = length(var.backendServers)
  route_table_id            = aws_route_table.backend[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat[count.index].id
}
# #

#
# #  associate subnets with route table id
resource "aws_route_table_association" "backend" {
  count          = length(var.backendServers)
  subnet_id      = aws_subnet.backend_subnets[count.index].id
  route_table_id = aws_route_table.backend[count.index].id
}
#
# # # ******************************************backend end ********************************************
#
# # ***************************************** db ****************************************************
#
# # create db subnets / servers
resource "aws_subnet" "db_subnets" {
  count       = length(var.dbServers)
  vpc_id      = aws_vpc.vpc.id
  cidr_block  = var.dbServers[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-db-${count.index+1}"
  }
}
#
# # create Route table for db
resource "aws_route_table" "db" {
  count   = length(var.dbServers)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-db-route-${count.index+1}"
  }
}
#  add default vpc cidr block to route_table
resource "aws_route" "db_route" {
  count                     = length(var.dbServers)
  route_table_id            = aws_route_table.db[count.index].id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
#
#  associate db subnets with nat
resource "aws_route" "db_nat" {
  count                     = length(var.dbServers)
  route_table_id            = aws_route_table.db[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat[count.index].id
}
#  associate subnets with route table id
resource "aws_route_table_association" "db" {
  count          = length(var.dbServers)
  subnet_id      = aws_subnet.db_subnets[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}
# #  **************************************** db end *************************************************
#
# # ***************************************** public *************************************************
#
# #  create public subnets/servers
resource "aws_subnet" "public_subnets" {
  count       = length(var.publicServers)
  vpc_id      = aws_vpc.vpc.id
  cidr_block  = var.publicServers[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.env}-public-subnets-${count.index+1}"
  }
}
#
# #  create Route table for public subnets
resource "aws_route_table" "public" {
  count   = length(var.publicServers)
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-public-route-${count.index+1}"
  }
}
#
# #  create a Route
resource "aws_route" "public_route" {
  count                     = length(var.publicServers)
  route_table_id            = aws_route_table.public[count.index].id
  destination_cidr_block    = var.default_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
#
# #  connect internet gateway to public subnets
resource "aws_route" "public_igw" {
  count                     = length(var.publicServers)
  route_table_id            = aws_route_table.public[count.index].id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.igw.id
}
#
# #  associate subnets with route table id
resource "aws_route_table_association" "public" {
  count          = length(var.publicServers)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


#  add destination vpc cidr block to default route table id
resource "aws_route" "default_edit_route" {
  route_table_id            = var.default_vpc_route_table_id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


