resource "aws_security_group" "instance_sg" {
  description = var.description
  vpc_id      = var.vpc_id
  name        = var.sg_name

  tags = {
    Name = var.sg_name
  }

  # HTTP access from the ALB security group
  ingress {
    from_port       = var.from_port
    to_port         = var.to_port
    protocol        = "tcp"
    security_groups = ["${var.from_sg_id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
