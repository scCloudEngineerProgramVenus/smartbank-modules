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