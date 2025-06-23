# module "frontend" {
#   depends_on      = [module.backend]
#   source          = "./module/app"
#   instance_type   = var.instance_type
#   component       = "frontend"
#   env             = var.env
#   zone_id         = var.zone_id
#   vault_token     = var.vault_token
#   subnets         = module.VPCInternet.frontend
#   vpc_id          = module.vpc
# }
#  module "backend" {
#    depends_on      = [module.mysql]
#    source          = "./module/app"
#    instance_type   = var.instance_type
#    component       = "backend"
#    env             = var.env
#    zone_id         = var.zone_id
#    vault_token     = var.vault_token
#    subnets         = module.VPCInternet.backend
#    vpc_id          = module.vpc
#    }

module "mysql" {
   source          = "./module/app"
   instance_type   = var.instance_type
   component       = "mysql"
   env             = var.env
   zone_id         = var.zone_id
   vault_token     = var.vault_token
   subnets         = module.VPCInternet.db
   vpc_id          = module.vpc

}

# module "singleVPCServer" {
#   source                     =  "./module/singleVPCServer"
#   vpc_cidr_block             =  var.vpc_cidr_block
#   env                        =  var.env
#   subnet_cidr_block          = var.subnet_cidr_block
#   default_vpc_id             = var.default_vpc_id
#   default_vpc_cidr_block     = var.default_vpc_cidr_block
#   default_vpc_route_table_id = var.default_vpc_route_table_id
#   vpc_route_table_id         = var.vpc_route_table_id
# }
# module "multiServerVPC"{
# source                 = "./module/VPC/VPCMultiServer"
# frontendServers        = var.frontendServers
# backendServers         = var.backendServers
# dbServers              = var.dbServers
# env                    = var.env
# vpc_cidr_block         = var.vpc_cidr_block
# default_vpc_id         = var.default_vpc_id
# availability_zone      = var.availability_zone
# default_vpc_cidr_block = var.default_vpc_cidr_block
# default_vpc_route_table_id = var.default_vpc_route_table_id
# vpc_route_table_id         = var.vpc_route_table_id
#
# }

module "VPCInternet"{
source = "./module/VPC/VPCInternet"
# frontendServers        = var.frontendServers
# backendServers         = var.backendServers
dbServers              = var.dbServers
# publicServers          = var.publicServers
env                    = var.env
vpc_cidr_block         = var.vpc_cidr_block
default_vpc_id         = var.default_vpc_id
availability_zone      = var.availability_zone
default_vpc_cidr_block = var.default_vpc_cidr_block
default_vpc_route_table_id = var.default_vpc_route_table_id

}

