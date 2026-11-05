resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count  = var.public_subnet_count

  cidr_block        = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "webtier_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count  = var.webtier_private_subnet_count

  cidr_block        = element(var.webtier_private_subnet_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)

  tags = {
    Name = "webtier_subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "apptier_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count  = var.apptier_private_subnet_count

  cidr_block        = element(var.apptier_private_subnet_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)

  tags = {
    Name = "apptier_subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "dbtier_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  count  = var.dbtier_private_subnet_count

  cidr_block        = element(var.dbtier_private_subnet_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.az.names, count.index)

  tags = {
    Name = "dbtier_subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_eip" "my_eip" {
  count  = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip[count.index].id
  count         = var.public_subnet_count
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "my_nat_gateway-${count.index + 1}"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my_igw]
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "public-RT"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_route_association" {
  count          = var.public_subnet_count
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

resource "aws_route_table" "webtier_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  count  = var.webtier_private_subnet_count

  tags = {
    Name = "webtier-RT-${count.index + 1}"
  }
}

resource "aws_route" "webtier_route" {
  count                  = var.webtier_private_subnet_count
  route_table_id         = aws_route_table.webtier_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway[count.index].id
}

resource "aws_route_table_association" "webtier_route_association" {
  count          = var.webtier_private_subnet_count
  route_table_id = aws_route_table.webtier_route_table[count.index].id
  subnet_id      = aws_subnet.webtier_subnet[count.index].id
}


resource "aws_route_table" "apptier_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  count  = var.apptier_private_subnet_count

  tags = {
    Name = "apptier-RT-${count.index + 1}"
  }
}

resource "aws_route" "apptier_route" {
  count                  = var.apptier_private_subnet_count
  route_table_id         = aws_route_table.apptier_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway[count.index].id
}

resource "aws_route_table_association" "apptier_route_association" {
  count          = var.apptier_private_subnet_count
  route_table_id = aws_route_table.apptier_route_table[count.index].id
  subnet_id      = aws_subnet.apptier_subnet[count.index].id
}

resource "aws_route_table" "dbtier_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  count  = var.dbtier_private_subnet_count

  tags = {
    Name = "dbtier-RT-${count.index + 1}"
  }
}

resource "aws_route" "dbtier_route" {
  count                  = var.dbtier_private_subnet_count
  route_table_id         = aws_route_table.dbtier_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat_gateway[count.index].id
}

resource "aws_route_table_association" "dbtier_route_association" {
  count          = var.dbtier_private_subnet_count
  route_table_id = aws_route_table.dbtier_route_table[count.index].id
  subnet_id      = aws_subnet.dbtier_subnet[count.index].id
}
