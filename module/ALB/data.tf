data "aws_instances" "app_components" {
  filter {
    name   = "tag:Name"
    values = ["frontend", "backend", "mysql"]
  }
}
