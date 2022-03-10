resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

locals {
  public_subnets = [
    {
      resource_name     = "public1"
      cidr_block        = "10.0.0.0/24"
      availability_zone = "${var.region_name}a"
      name              = "venus-public-subnet-01"
    },
    {
      resource_name     = "public2"
      cidr_block        = "10.0.10.0/24"
      availability_zone = "${var.region_name}b"
      name              = "venus-public-subnet-02"
    }
  ]

  private_subnets = [
    {
      resource_name     = "private1"
      cidr_block        = "10.0.20.0/24"
      availability_zone = "${var.region_name}a"
      name              = "venus-private-subnet-01"
    },
    {
      resource_name     = "private2"
      cidr_block        = "10.0.30.0/24"
      availability_zone = "${var.region_name}b"
      name              = "venus-private-subnet-02"
    }
  ]

  db_subnets = [
    {
      resource_name     = "privatedb1"
      cidr_block        = "10.0.40.0/24"
      availability_zone = "${var.region_name}a"
      name              = "venus-db-private-subnet-01"
    },
    {
      resource_name     = "private2"
      cidr_block        = "10.0.50.0/24"
      availability_zone = "${var.region_name}b"
      name              = "venus-db-private-subnet-02"
    }
  ]
}

module "public_subnets" {
  source     = "./Subnets"
  count      = length(local.public_subnets)
  name       = local.public_subnets[count.index].name
  az         = local.public_subnets[count.index].availability_zone
  cidr_block = local.public_subnets[count.index].cidr_block
  vpc_id     = aws_vpc.main.id
}

module "private_subnets" {
  source     = "./Subnets"
  count      = length(local.private_subnets)
  name       = local.private_subnets[count.index].name
  az         = local.private_subnets[count.index].availability_zone
  cidr_block = local.private_subnets[count.index].cidr_block
  vpc_id     = aws_vpc.main.id
}

module "db_subnets" {
  source     = "./Subnets"
  count      = length(local.db_subnets)
  name       = local.db_subnets[count.index].name
  az         = local.db_subnets[count.index].availability_zone
  cidr_block = local.db_subnets[count.index].cidr_block
  vpc_id     = aws_vpc.main.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-gw"
  }
}

resource "aws_eip" "eip" {}

resource "aws_eip" "eip2" {}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "${var.vpc_name}-nat-01"
  }
  depends_on = [aws_internet_gateway.gw, aws_eip.eip]
}
