# create application load balancer
resource "aws_lb" "alb"  {
  name               = "altschool-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group]
  subnets            = var.subnet_id[*]
  enable_deletion_protection = false

  tags   = {
    Name = "${var.project_name}-alb"
  }
}

# create target group
resource "aws_lb_target_group" "alb_target_group" {
  name        = "altschool-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.test_vpc_id

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_lb_target_group_attachment" "altschool-tg-attach" {
  count = length(var.public_subnet_cidr)
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id = var.instance_ids[count.index]
}

# create a listener on port 80 with redirect action
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

# Now, Lets get my hosted zone details.
# My hosted zone is created in us-east-1
# So, note the region where you run this terraform script.
data "aws_route53_zone" "ade_hosted_zone" {
  name = var.domain_name
}

# OK, Lets create a record set in route53
resource "aws_route53_record" "sub_domain1" {
  zone_id = data.aws_route53_zone.ade_hosted_zone.zone_id
  name = var.record_name1
  type = "A"

  alias {
    name = aws_lb.alb.dns_name
    zone_id = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}