// Enter the following commands in terminal
// Mac user:
// export TF_VAR_access_key=(the access_key)
// export TF_VAR_secret_key=(the secret_key)
// terraform plan/apply
// Windows user:
// $env:TF_VAR_access_key="access_key"
// $env:TF_VAR_secret_key="secret_key"
// terraform plan/apply
provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source      = "./modules/VPC"
  vpc_name    = "bobby-test"
  region_name = var.aws_region
}

module "venus_alb" {
  source    = "./modules/ApplicationLoadBalancer"
  alb_name  = "Venus-test-alb"
  vpc_id    = module.vpc.id
  subnet_id = module.vpc.public_subnets_id[*].id
}

module "FE_instance_sg" {
  source      = "./modules/SecurityGroups"
  description = "Venus FE Instance Security Group"
  sg_name     = "Venus FE instance test"
  vpc_id      = module.vpc.id
  from_port   = 80
  to_port     = 80
  from_sg_id  = module.venus_alb.alb_sg_id
}

module "BE_instance_sg" {
  source      = "./modules/SecurityGroups"
  description = "Venus BE Instance Security Group"
  sg_name     = "Venus BE instance test"
  vpc_id      = module.vpc.id
  from_port   = 8080
  to_port     = 8080
  from_sg_id  = module.venus_alb.alb_sg_id
}

module "DB_sg" {
  source      = "./modules/SecurityGroups"
  description = "Venus DB Security Group"
  sg_name     = "Venus DB test"
  vpc_id      = module.vpc.id
  from_port   = 5432
  to_port     = 5432
  from_sg_id  = module.BE_instance_sg.id
}

module "db" {
  source              = "./modules/DB"
  subnet_ids          = module.vpc.db_subnets_id[*].id
  name                = "venus-db"
  security_groups_ids = ["${module.DB_sg.id}"]
}

module "venus_asg" {
  source              = "./modules/AutoScalingGroups"
  vpc_id              = module.vpc.id
  FE_sg_id            = module.FE_instance_sg.id
  BE_sg_id            = module.BE_instance_sg.id
  subnets             = module.vpc.private_subnets_id[*].id
  FE_target_group_arn = module.venus_alb.FE_target_group_arn
  BE_target_group_arn = module.venus_alb.BE_target_group_arn
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1
  alb_endpoint        = module.venus_alb.alb_dns
  db_endpoint         = module.db.endpoint
}

/*

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
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
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
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
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
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
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

resource "aws_eip" "eip" {}

resource "aws_eip" "eip2" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "venus-nat-01"
  }
  depends_on = [aws_internet_gateway.gw, aws_eip.eip]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "venus-nat-02"
  }
  depends_on = [aws_internet_gateway.gw, aws_eip.eip]
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
  db_dns              = aws_db_instance.new.endpoint
}
*/
