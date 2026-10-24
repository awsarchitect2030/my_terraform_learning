resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.myvpc.id
  count  = var.public_subnet_count

  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public_subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.myvpc.id
  count  = var.private_subnet_count

  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${var.environment}-private_subnet-${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name        = "${var.environment}-public_route_table"
    Environment = var.environment
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_route_association" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.myvpc.id
  count  = var.private_subnet_count

  tags = {
    Name        = "${var.environment}-private_route_table_${count.index + 1}"
    Environment = var.environment
  }
}

resource "aws_route" "private_route" {
  count                  = var.private_subnet_count
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.my_NAT_GW[count.index].id
}

resource "aws_route_table_association" "private_route_association" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_nat_gateway" "my_NAT_GW" {
  count         = var.private_subnet_count
  subnet_id     = aws_subnet.public_subnet[count.index].id
  allocation_id = aws_eip.eip[count.index].id

  tags = {
    Name        = "${var.environment}-NAT-gw-${count.index + 1}"
    Environment = var.environment
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my_igw]
}

resource "aws_eip" "eip" {
  domain = "vpc"
  count  = var.private_subnet_count

  tags = {
    Name        = "${var.environment}-nat-eip-az-${count.index + 1}"
    Environment = var.environment
  }
}

