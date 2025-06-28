data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "RHEL-9-DevOps-Practice"
  owners           = [973714476881]
}
// this data will retrieve in json format
data "vault_generic_secret" "get_secrets" {
  path = "common/elastisearch"
}


