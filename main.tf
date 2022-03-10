provider "aws" {
  region     = var.aws_region
  access_key = ""
  secret_key = ""
}

/*
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Venus"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ca-central-1a"
  tags = {
    Name = "venus-public-subnet-01"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ca-central-1b"
  tags = {
    Name = "venus-public-subnet-02"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "ca-central-1a"
  tags = {
    Name = "venus-private-subnet-01"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private2" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.30.0/24"
  availability_zone = "ca-central-1b"
  tags = {
    Name = "venus-private-subnet-02"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "privatedb" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.40.0/24"
  availability_zone = "ca-central-1a"
  tags = {
    Name = "venus-db-private-subnet-01"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "privatedb2" {

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.50.0/24"
  availability_zone = "ca-central-1b"
  tags = {
    Name = "venus-db-private-subnet-02"
  }
  depends_on = [aws_vpc.main]
}
*/
resource "aws_security_group" "all" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-sg"
  }
  name = "venus-sg"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "FELB" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-FE-LB"
  }
  name = "venus-FE-LB"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "BELB" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-BE-LB"
  }
  name = "venus-BE-LB"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "FEEC2" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-FE-instance"
  }
  name = "venus-FE-instance"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.FELB.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "BEEC2" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-BE-instance"
  }
  name = "venus-BE-instance"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = ["${aws_security_group.BELB.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "DB" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-DB"
  }
  name = "venus-DB"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = ["${aws_security_group.BEEC2.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-public-route"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  depends_on = [aws_vpc.main, aws_internet_gateway.gw]
}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-private-route-01"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "private2" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-private-route-02"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "dbprivate" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-db-private-route"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "venus-gw"
  }
  depends_on = [aws_vpc.main]
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
/*
resource "aws_db_subnet_group" "new" {
  name       = "venus-db-subnet-group"
  subnet_ids = [aws_subnet.privatedb.id, aws_subnet.privatedb2.id]

  tags = {
    Name = "venus-db-subnet-group"
  }
  depends_on = [aws_subnet.privatedb, aws_subnet.privatedb2]
}

resource "aws_db_instance" "new" {
  instance_class       = "db.t3.micro"
  password             = "postgres"
  username             = "postgres"
  storage_encrypted    = true
  db_name              = "smartbankdb"
  identifier           = "venus-db-test"
  db_subnet_group_name = aws_db_subnet_group.new.name
  vpc_security_group_ids = [
    "${aws_security_group.DB.id}",
  ]
  multi_az            = true
  allocated_storage   = 10
  engine              = "postgres"
  engine_version      = "14.1"
  skip_final_snapshot = true
}
*/
resource "aws_eip" "eip" {}

resource "aws_eip" "eip2" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "venus-nat-01"
  }
  depends_on = [aws_internet_gateway.gw,aws_eip.eip]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "venus-nat-02"
  }
  depends_on = [aws_internet_gateway.gw,aws_eip.eip]
}

module "venus_alb" {
  source   = "./modules/ApplicationLoadBalancer"
  alb_name = "Venus-test-alb"
  vpc_id   = aws_vpc.main.id
  subnet_id = [
    "${aws_subnet.public.id}",
    "${aws_subnet.public2.id}"
  ]
}

module "venus_asg" {
  source    = "./modules/AutoScalingGroups"
  vpc_id    = aws_vpc.main.id
  alb_sg_id = module.venus_alb.alb_sg_id
  subnets = [
    "${aws_subnet.private.id}",
    "${aws_subnet.private2.id}"
  ]
  FE_target_group_arn = module.venus_alb.FE_target_group_arn
  BE_target_group_arn = module.venus_alb.BE_target_group_arn
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  alb_dns             = module.venus_alb.alb_dns
  db_dns = aws_db_instance.new.endpoint
}

/*
resource "aws_lb" "lb" {

  subnet_mapping {
    subnet_id     = aws_subnet.public.id
  }
    subnet_mapping {
    subnet_id     = aws_subnet.public2.id
  }
   name = "venus-lb"
   security_groups = [
    aws_security_group.FELB.id,aws_security_group.BELB.id
  ]


depends_on = [aws_vpc.main,aws_subnet.public,aws_subnet.public2]
}

resource "aws_lb_target_group" "FE" {
 
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  name = "venus-FE-TG"
  depends_on = [aws_lb.lb]

}

resource "aws_lb_target_group" "BE" {

  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  name = "venus-BE-TG"
  depends_on = [aws_lb.lb]
}

resource "aws_launch_template" "FE" {

   name = "venus-FE-template"
   instance_type = "t2.micro"
   image_id      = "ami-041d49677629acc40"
//   security_group_names = [
//      "${aws_security_group.FEEC2.name}"
//   ]
  tags = {
   Name = "venus-FE"
  }

}

resource "aws_launch_template" "BE" {

   name = "venus-BE-template"
   instance_type = "t2.micro"
   image_id      = "ami-041d49677629acc40"
//   security_group_names = [
//      "${aws_security_group.BEEC2.name}"
//   ]
  tags = {
   Name = "venus-BE"
  }

}

resource "aws_autoscaling_group" "FE" {
vpc_zone_identifier = [aws_subnet.private.id, aws_subnet.private2.id]
min_size = 1
max_size = 1
launch_template {
   id      = aws_launch_template.FE.id
   version = "$Latest"
  }    
depends_on = [aws_vpc.main,aws_subnet.private,aws_subnet.private2,aws_launch_template.FE] 
name = "venus-FE-ASG"
}

resource "aws_autoscaling_group" "BE" {
vpc_zone_identifier = [aws_subnet.private.id, aws_subnet.private2.id]
min_size = 1
max_size = 1   
launch_template {
    id      = aws_launch_template.BE.id
    version = "$Latest"
  }
depends_on = [aws_vpc.main,aws_subnet.private,aws_subnet.private2,aws_launch_template.BE] 
name = "venus-BE-ASG"
}
*/



/*
resource "aws_lb_target_group_attachment" "FE" {
  target_group_arn = aws_lb_target_group.FE.arn
  target_id        = aws_launch_template.FE
  port             = 80
  depends_on = [aws_lb_target_group.FE,aws_launch_template.FE]
}

resource "aws_lb_target_group_attachment" "BE" {
  target_group_arn = aws_lb_target_group.BE.arn
  target_id        = aws_launch_template.BE
  port             = 8080
  depends_on = [aws_lb_target_group.BE,aws_launch_template.BE]
}

resource "aws_lb_listener" "FE" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.FE.arn
  }
  depends_on = [aws_lb.lb,aws_lb_target_group.FE]
}

resource "aws_lb_listener" "BE" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.BE.arn
  }
  depends_on = [aws_lb.lb,aws_lb_target_group.BE]
}

resource "aws_instance" "FE" {
launch_template {
    id      = aws_launch_template.FE.id
    version = "$Latest"
  }
  depends_on = [aws_launch_template.FE]
  tags = {
   Name = "venus-FE"
  }
}

resource "aws_instance" "BE" {
launch_template {
    id      = aws_launch_template.BE.id
    version = "$Latest"
  }
  depends_on = [aws_subnet.private]
  tags = {
   Name = "venus-BE"
  }
}
*/
