resource "aws_instance" "component" {
  ami = data.aws_ami.ami.image_id
  instance_type = var.instance_type
  subnet_id        = var.subnet_id[0]
  vpc_security_group_ids = [aws_security_group.sg.id]
  instance_market_options {
      market_type = "spot"
      spot_options {
        instance_interruption_behavior = "stop"
        spot_instance_type             = "persistent"
      }
    }
#  to encrypt the disk by using kms key id
root_block_device {
    encrypted    = true
    kms_key_id   = var.kms_key_id
    volume_type  = var.volume_type
    }

    tags = {
    Name = var.component
    monitor= "yes"
    env = var.env
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}

#  create a security group for custom VPC
resource "aws_security_group" "sg" {
  name                 =    "${var.env}-custom-vpc-sg"
  description          =    "Allow TLS inbound traffic and all outbound traffic"
  vpc_id               =    var.vpc_id
   ingress {
      from_port        =     22
      to_port          =     22
      protocol         =    "tcp"
      cidr_blocks      =    var.bastion_node
     }
   ingress {
         from_port        =     var.app_port
         to_port          =     var.app_port
         protocol         =    "tcp"
         cidr_blocks      =    var.server_app_port
        }
   egress {
      from_port        =     0
      to_port          =     0
      protocol         =    "-1"
      cidr_blocks      =    ["0.0.0.0/0"]
     }
  tags = {
     Name = "${var.env}-sg"
   }
  }

resource "null_resource" "provisioner" {
    connection {
        type         =  "ssh"
        user         =  jsondecode(data.vault_generic_secret.get_secrets.data_json).ansible_user
        password     =  jsondecode(data.vault_generic_secret.get_secrets.data_json).ansible_password
        host         =  aws_instance.component.private_ip
        port         =  22
      }
   provisioner "remote-exec" {
    inline = [
      "sudo pip3.11 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/pdevops78/expense-ansible getsecrets.yml -e env=${var.env} -e component_name=${var.component} -e project_name=expense",
      "ansible-pull -i localhost, -U https://github.com/pdevops78/expense-ansible expense.yml -e env=${var.env} -e component_name=${var.component} -e @~/secrets.json"

    ]
  }

}
resource "aws_route53_record" "server_route" {
  count              = var.lb_needed ? 0 : 1
  name               = "${var.component}-${var.env}.pdevops78.online"
  type               = "A"
  zone_id            = var.zone_id
  records            = [aws_instance.component.public_ip]
  ttl                = 30
}

resource "aws_route53_record" "lb_route" {
  count              = var.lb_needed ? 1 : 0
  name               = "${var.component}-${var.env}.pdevops78.online"
  type               = "CNAME"
  zone_id            = var.zone_id
  records            = [aws_lb.alb[0].dns_name]
  ttl                = 30
}

resource "aws_lb" "alb" {
  count              = var.lb_needed ? 1 : 0
  name               = "${var.env}-${var.component}-alb"
  internal           = var.lb_type == "public" ? false : true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg[0].id]
  subnets            = var.lb_subnets
    tags = {
    Name = "${var.env}-${var.component}-alb"
  }
}

# create target group
resource "aws_lb_target_group" "tg" {
  count    = var.lb_needed ? 1 : 0
  name     = "${var.env}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
 health_check {
     interval = 30
     path = "/health"
     timeout = 5
     healthy_threshold = 2
     unhealthy_threshold = 2
   }
}

resource "aws_lb_target_group_attachment" "tg_attach" {
  target_group_arn = aws_lb_target_group.tg[0].id
  target_id        = aws_instance.component.id
  port             = 80
}

resource "aws_lb_listener" "frontend_http_listener" {
  count             = var.lb_needed && var.lb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
}

resource "aws_lb_listener" "frontend_https_listener" {
  count             = var.lb_needed && var.lb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
}

 resource "aws_lb_listener" "backend_listener" {
   count             = var.lb_needed && var.lb_type != "public" ? 1 : 0
   load_balancer_arn = aws_lb.alb[0].arn
   port              = "8080"
   protocol          = "HTTP"
   default_action {
     type             = "forward"
     target_group_arn = aws_lb_target_group.tg[0].arn
   }
   }

# create a security group for Application Load Balancer

resource "aws_security_group" "alb_sg" {
  count                =    var.lb_needed ? 1 : 0
  name                 =    "${var.env}-alb-sg"
  description          =    "Allow TLS inbound traffic and all outbound traffic"
  vpc_id               =    var.vpc_id
   dynamic "ingress" {
      for_each = var.lb_app_port
      content {
              from_port   = ingress.value
              to_port     = ingress.value
              protocol    = "tcp"
              cidr_blocks      =    var.lb_server_app_port
              }
     }
   egress {
      from_port        =     0
      to_port          =     0
      protocol         =    "-1"
      cidr_blocks      =    ["0.0.0.0/0"]
     }
  tags = {
     Name = "${var.env}-alb"
   }
  }


