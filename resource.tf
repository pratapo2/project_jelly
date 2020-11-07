resource "aws_instance" "wb" {
 ami = "${var.ami}"
 instance_type = "t2.micro"
 key_name = "devops"
 subnet_id = "${aws_subnet.public-subnet-1.id}"
 vpc_security_group_ids = ["${aws_security_group.sgweb.id}"] 
 associate_public_ip_address = true
 source_dest_check = false

 tags = {
   Name = "webserver-1"
 }
}

resource "aws_instance" "wb-2" {
 ami = "${var.ami}"
 instance_type = "t2.micro"
 key_name = "devops"
 subnet_id = "${aws_subnet.public-subnet-1.id}"
 vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
 associate_public_ip_address = true
 source_dest_check = false

 tags = {
   Name = "webserver-2"
 }
}

# Define TG

resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-0111eba15e5508c94"
}


# for attach EC2 
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id        = "i-0c39158b7fbeaa6f4"
  port             = 80
}

resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id        = "i-0eb6c113e1101d18c"
  port             = 80
}

# For ELB

resource "aws_lb" "my-aws-alb" {
  name     = "my-test-alb"
  internal = false

security_groups = [
    "sg-0ad243b599f1ff703",
  ]

subnets = [
    "subnet-0df1f836f695ed16b",
    "subnet-07814dfcfe471f51b",
  ]

tags = {
    Name = "my-test-alb"
  }

ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.my-aws-alb.arn}"
  port              = 80
  protocol          = "HTTP"

default_action {
    type             = "forward"
    target_group_arn = "arn:aws:elasticloadbalancing:ap-south-1:000755452046:targetgroup/my-test-tg/d8205b1b5b6ec31c"
  }
}
