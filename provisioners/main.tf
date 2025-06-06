resource "aws_instance" "instance" {
  ami = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "demo"
  }
}
resource "null_resource" "resource" {
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = var.ssh_user
      password = var.ssh_pass
      host = aws_instance.instance.public_ip
    }
    inline = [
      "sudo dnf install nginx -y"

    ]
  }
}


