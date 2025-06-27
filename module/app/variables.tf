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







