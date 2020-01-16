# Creating Application Load Balancer

resource "aws_lb" "ALB" {
  name               = "ALB-Terra"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.sample_http_ssh.id}"]
  subnets            = ["${aws_subnet.public_subnet.id}", "${aws_subnet.private_subnet.id}"]
}

# Creating a Target Group

resource "aws_lb_target_group" "TG" {
  name     = "TG-Terra"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.Sample_vpc.id}"

}

# Creating Listeners

resource "aws_lb_listener" "Application" {
  load_balancer_arn = "${aws_lb.ALB.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.TG.arn}"
  }
}
