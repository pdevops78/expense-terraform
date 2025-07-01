# module "frontend" {
# #   depends_on      = [module.backend]
#   source          = "./module/app"
#   instance_type   = var.instance_type
#   component       = "frontend"
#   env             = var.env
#   zone_id         = var.zone_id
#   vault_token     = var.vault_token
#   subnet_id       = module.AppLoadBalancer.frontend
#   vpc_id          = module.AppLoadBalancer.vpc_id
#   lb_needed       = true
#   lb_type         = "public"
#   lb_subnets      = module.AppLoadBalancer.public
#   server_app_port = var.publicServers
#   lb_server_app_port = ["0.0.0.0/0"]
#   app_port         = 80
#   lb_app_port      = {http:80,https:443}
#   bastion_node     = var.bastion_node
#   certificate_arn  = var.certificate_arn
#   ssl_policy       = var.ssl_policy
#   volume_type = var.volume_type
# }

module "frontend"{
source             = "./module/autoscaling"
component          = "frontend"
env                = var.env
instance_type      = var.instance_type
subnet_id          = module.AppLoadBalancer.frontend
server_app_cidr    = var.publicServers
app_port           = 80
vpc_id             = module.AppLoadBalancer.vpc_id
bastion_node       = var.bastion_node
lb_subnets         = module.AppLoadBalancer.public
lb_app_port        = {http:80,https:443}
lb_server_app_cidr = ["0.0.0.0/0"]
lb_type            = "public"
ssl_policy         = var.ssl_policy
certificate_arn    = var.certificate_arn
zone_id            = var.zone_id
}

module "backend"{
source             = "./module/autoscaling"
component          = "backend"
env                = var.env
instance_type      = var.instance_type
subnet_id          = module.AppLoadBalancer.backend
server_app_cidr    = concat(var.frontendServers,var.backendServers)
app_port           = 8080
vpc_id             = module.AppLoadBalancer.vpc_id
bastion_node       = var.bastion_node
lb_subnets         = module.AppLoadBalancer.frontend
lb_app_port        = {http:8080}
lb_server_app_cidr = var.backendServers
lb_type            = "private"
ssl_policy         = var.ssl_policy
certificate_arn    = var.certificate_arn
zone_id            = var.zone_id
}

# module "rds"{
# source = "./module/rds"
# component="mysql"
# allocated_storage = 20
# engine = "mysql"
# engine_version = "8.0.36"
# instance_class = "db.t3.micro"
# storage_type = "gp3"
# publicly_accessible = "no"
# family = "mysql8.0"
# multi_az = false
# vpc_id = module.AppLoadBalancer.vpc_id
# env=var.env
# skip_final_snapshot = true
# server_app_port = var.backendServers
# subnet_id = module.AppLoadBalancer.db
# kms_key_id = var.kms_key_id
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
#     vpc_id          = module.VPCInternet.vpc_id
#     lb_needed       = true
#     lb_type        = "private"
#    }
#
# module "mysql" {
#    source          = "./module/app"
#    instance_type   = var.instance_type
#    component       = "mysql"
#    env             = var.env
#    zone_id         = var.zone_id
#    vault_token     = var.vault_token
#    subnet_id        = module.AppLoadBalancer.db
#    vpc_id          = module.AppLoadBalancer.vpc_id
#
# }

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

# module "VPCInternet"{
# source = "./module/VPC/VPCInternet"
# frontendServers        = var.frontendServers
# backendServers         = var.backendServers
# dbServers              = var.dbServers
# publicServers          = var.publicServers
# env                    = var.env
# vpc_cidr_block         = var.vpc_cidr_block
# default_vpc_id         = var.default_vpc_id
# availability_zone      = var.availability_zone
# default_vpc_cidr_block = var.default_vpc_cidr_block
# default_vpc_route_table_id = var.default_vpc_route_table_id
# }

module "AppLoadBalancer"{
source  = "./module/VPC/AppLoadBalancer"
env    = var.env
vpc_cidr_block = var.vpc_cidr_block
frontendServers = var.frontendServers
availability_zone = var.availability_zone
default_vpc_id    = var.default_vpc_id
default_vpc_cidr_block = var.default_vpc_cidr_block
default_vpc_route_table_id = var.default_vpc_route_table_id
publicServers = var.publicServers
dbServers     = var.dbServers
backendServers = var.backendServers
}

# module "ALB"{
# source = "./module/ALB"
# internal = false
# vpc_id = module.AppLoadBalancer.vpc_id
# env= var.env
# subnets = module.AppLoadBalancer.public
# }


# module "rds"{
# source = "./module/rds"
# component="mysql"
# allocated_storage = 20
# engine = "mysql"
# engine_version = "8.0.36"
# instance_class = "db.t3.micro"
# storage_type = "gp3"
# publicly_accessible = "no"
# family = "mysql8.0"
# multi_az = false
# vpc_id = module.AppLoadBalancer.vpc_id
# env=var.env
# skip_final_snapshot = true
# server_app_port = var.backendServers
# subnet_id = module.AppLoadBalancer.db
# kms_key_id = var.kms_key_id
# }



