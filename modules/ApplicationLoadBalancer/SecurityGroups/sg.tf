resource "aws_security_group" "alb_sg" {
  description = var.description
  vpc_id      = var.vpc_id
  name        = var.sg_name

  tags = {
    Name = var.sg_name
  }

  # HTTP on port 8080 access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP on port 80 access from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}