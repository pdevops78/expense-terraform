variable "instance_type" {}
variable "component" {}
variable "env" {}
variable "zone_id"{}
variable "vault_token"{}
variable "vpc_id"{}
variable "subnet_id"{}
variable "lb_needed"{
default = false
}
variable "lb_type"{
default = null
}
variable "lb_subnets"{}
variable "server_app_port"{}
variable "app_port"{}
variable "lb_server_app_port"{}
variable "bastion_node"{}
variable "certificate_arn"{}
variable "ssl_policy"{}







