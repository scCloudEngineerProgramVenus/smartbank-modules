
resource "aws_db_subnet_group" "new" {
  name       = "venus-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "venus-db-subnet-group"
  }
}

resource "aws_db_instance" "new" {
  instance_class         = "db.t3.micro"
  password               = "postgres"
  username               = "postgres"
  storage_encrypted      = true
  db_name                = "smartbankdb"
  identifier             = var.name
  db_subnet_group_name   = aws_db_subnet_group.new.name
  vpc_security_group_ids = var.security_groups_ids
  multi_az               = true
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "14.1"
  skip_final_snapshot    = true
}
