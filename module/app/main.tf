resource "aws_instance" "component" {
  ami = data.aws_ami.ami.image_id
  instance_type = var.instance_type
  instance_market_options {
      market_type = "spot"
      spot_options {
        instance_interruption_behavior = "stop"
        spot_instance_type             = "persistent"
      }
    }
    tags = {
    Name = var.component
    monitor= "yes"
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}
resource "null_resource" "provisioner" {
  provisioner "remote-exec" {
    connection {
      type         = "ssh"
      user         =  var.ssh_user
      password     =  var.ssh_pass
      host         = aws_instance.component.public_ip
      port         = 22
    }
    inline = [
      "sudo pip3.11 install ansible -y",
      "ansible-pull -i localhost, -U https://github.com/pdevops78/expense-ansible expense.yml -e env=${var.env} -e component_name=${var.component}"
    ]
  }
}
resource "aws_route53_record" "route" {
  name               = "${var.component}-${var.env}.pdevops78.online"
  type               = "A"
  zone_id            = var.zone_id
  records            = [aws_instance.component.private_ip]
  ttl                = 30
}




