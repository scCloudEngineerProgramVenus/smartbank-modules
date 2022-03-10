module "alb_sg" {
  source      = "./SecurityGroups"
  description = "Venus ALB sg"
  sg_name     = "Venus ALB sg"
  vpc_id      = var.vpc_id
}

resource "aws_lb" "Venus" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${module.alb_sg.alb_sg_id}"]

  subnets                    = var.subnet_id
  enable_deletion_protection = false

  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb_target_group" "alb_tg_FE" {
  name     = "tf-alb-tg-fe"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "alb_tg_BE" {
  name     = "tf-alb-tg-be"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Venus.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_FE.arn
  }
}

resource "aws_lb_listener" "back_end" {
  load_balancer_arn = aws_lb.Venus.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_BE.arn
  }
}
