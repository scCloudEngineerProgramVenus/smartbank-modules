resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = var.vpc_name
  }
}

// Declare subnet parameters
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

module "natGateways" {
  source           = "./NATgateway"
  count            = length(module.public_subnets)
  name             = "venus-nat-${count.index + 1}"
  public_subnet_id = module.public_subnets[count.index].id
}

locals {
  public_subnet_route_table = {
    vpc_id     = aws_vpc.main.id
    name       = "venus-public-route"
    gateway_id = aws_internet_gateway.gw.id
  }

  private_subnets_route_tables = [
    {
      vpc_id     = aws_vpc.main.id
      name       = "venus-private-route-01"
      gateway_id = module.natGateways[0].id
    },
    {
      vpc_id     = aws_vpc.main.id
      name       = "venus-private-route-02"
      gateway_id = module.natGateways[1].id
    }
  ]
}

module "public_subnet_route_table" {
  source     = "./RouteTable"
  vpc_id     = local.public_subnet_route_table.vpc_id
  name       = local.public_subnet_route_table.name
  gateway_id = local.public_subnet_route_table.gateway_id
}

module "private_subnet_route_tables" {
  source     = "./RouteTable"
  count      = length(local.private_subnets_route_tables)
  vpc_id     = local.private_subnets_route_tables[count.index].vpc_id
  name       = local.private_subnets_route_tables[count.index].name
  gateway_id = local.private_subnets_route_tables[count.index].gateway_id
}

resource "aws_route_table" "dbprivate" {

  vpc_id = aws_vpc.main.id
  tags = {
    Name = "venus-db-private-route"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(module.public_subnets)
  subnet_id      = module.public_subnets[count.index].id
  route_table_id = module.public_subnet_route_table.id
}

resource "aws_route_table_association" "private" {
  count          = length(module.private_subnets)
  subnet_id      = module.private_subnets[count.index].id
  route_table_id = module.private_subnet_route_tables[count.index].id
}

resource "aws_route_table_association" "db" {
  count          = length(module.db_subnets)
  subnet_id      = module.db_subnets[count.index].id
  route_table_id = aws_route_table.dbprivate.id
}
