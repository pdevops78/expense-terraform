// create launch template
resource "aws_launch_template" "template" {
  name = "${var.component}-${var.env}-lt"
  image_id = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids= [aws_security_group.sg.id]
  tags = {
  Name = "${var.component}-${var.env}-lt"
  }
 }

// create autoscaling group
resource "aws_autoscaling_group" "asg" {
  name                      = "${var.component}-${var.env}-asg"
  max_size                  = 5
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.subnet_id
  launch_template {
        id = aws_launch_template.template.id
        version = "$Latest"
  }
  }

# create a load balancer
resource "aws_lb" "alb" {
  name               = "${var.env}-${var.component}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.lb_subnets
    tags = {
    Name = "${var.env}-${var.component}-alb"
  }
}

#  create target group
resource "aws_lb_target_group" "tg" {
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

# create listener and redirect HTTP protocol to HTTPS protocol
resource "aws_lb_listener" "frontend_http_listener" {
  count             = var.lb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
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

# Redirect the load balancer listener 443
resource "aws_lb_listener" "frontend_https_listener" {
  count             = var.lb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# create a listener for load balancer
resource "aws_lb_listener" "backend_listener" {
  count             = var.lb_type != "public" ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
  }

# create route53 record with type CNAME
resource "aws_route53_record" "lb_route" {
  name               = "${var.component}-${var.env}.pdevops78.online"
  type               = "CNAME"
  zone_id            = var.zone_id
  records            = [aws_lb.alb.dns_name]
  ttl                = 30
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
         cidr_blocks      =    var.server_app_cidr
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

resource "aws_security_group" "alb_sg" {
  name                 =    "${var.env}-alb-sg"
  description          =    "Allow TLS inbound traffic and all outbound traffic"
  vpc_id               =    var.vpc_id
  dynamic "ingress" {
        for_each = var.lb_server_app_port
        content {
                from_port   = ingress.value
                to_port     = ingress.value
                protocol    = "tcp"
                cidr_blocks = var.lb_server_app_cidr
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

