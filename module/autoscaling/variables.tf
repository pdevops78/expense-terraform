variable "component"{}
variable "env"{}
variable "instance_type"{}
variable "subnet_id"{}
variable "app_port"{}
variable "server_app_cidr"{}
variable "vpc_id"{}
variable "bastion_node"{}
variable "lb_subnets"{}
variable "lb_app_port"{}
variable "lb_server_app_cidr"{}
variable "lb_type"{
  default = false
    }
variable "ssl_policy"{}
variable "certificate_arn"{}
variable "zone_id"{}
variable "kms_key_id"{}
