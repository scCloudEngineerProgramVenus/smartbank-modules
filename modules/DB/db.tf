
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