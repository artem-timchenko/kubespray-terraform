locals {
  dmz_cidrs           = [cidrsubnet(var.vpc_cidr, 2, 0), cidrsubnet(var.vpc_cidr, 2, 1)]
  priv_cidrs          = [cidrsubnet(var.vpc_cidr, 2, 2), cidrsubnet(var.vpc_cidr, 2, 3)]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_subnet" "subnet_dmz" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = local.dmz_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.environment}-subnet-dmz-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_subnet" "subnet_priv" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = local.priv_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project}-${var.environment}-subnet-priv-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project}-${var.environment}-igw-main"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_eip" "eip_natgw" {
	count = 2

  vpc = true
}

resource "aws_nat_gateway" "natgw" {
	count = 2

  allocation_id = aws_eip.eip_natgw[count.index].id
  subnet_id     = aws_subnet.subnet_dmz[count.index].id

  tags = {
    Name        = "${var.project}-${var.environment}-natgw-${count.index}"
    Environment = var.environment
    Project     = var.project
  }

  depends_on = [aws_internet_gateway.igw_main]
}

resource "aws_route_table" "rtb_dmz" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }

  tags = {
    Name        = "${var.project}-${var.environment}-rtb-dmz"
    Environment = var.environment
    Project     = var.project
  }

}

resource "aws_route_table_association" "rtb_dmz_to_dmz_subnets" {
	count = 2

  route_table_id = aws_route_table.rtb_dmz.id
  subnet_id      = aws_subnet.subnet_dmz[count.index].id
}

resource "aws_route_table" "rtb_priv" {
	count = 2

  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw[count.index].id
  }

  tags = {
    Name        = "${var.project}-${var.environment}-rtb-priv-${count.index}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route_table_association" "rtb_priv_to_priv_subnets" {
	count = 2

  route_table_id = aws_route_table.rtb_priv[count.index].id
  subnet_id      = aws_subnet.subnet_priv[count.index].id
}
