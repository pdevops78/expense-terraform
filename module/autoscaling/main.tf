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


resource "aws_lb" "alb" {
  name               = "${var.env}-${var.component}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg[0].id]
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

#  attach to an existing load balancer to autoscaling
resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  elb                    = aws_elb.alb.id
  lb_target_group_arn    = aws_lb_target_group.tg.arn
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
         cidr_blocks      =    ["0.0.0.0/0"]
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

