variable "instance_type" {}
variable "component" {}
variable "env" {}
variable "ssh_user"{}
variable "ssh_pass"{}
variable "zone_id"{}

output "env" {
  value = var.env
}




