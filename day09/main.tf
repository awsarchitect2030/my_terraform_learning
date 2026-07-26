resource "aws_vpc" "primary" {
  provider         = aws.primary
  cidr_block       = var.primary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "primary_vpc-${var.primary_region}"
  }
}

resource "aws_vpc" "secondary" {
  provider         = aws.secondary
  cidr_block       = var.secondary_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "primary_vpc-${var.secondary_region}"
  }
}

resource "aws_subnet" "primary_subnet" {
  provider   = aws.primary
  vpc_id     = aws_vpc.primary.id
  cidr_block = var.primary_subnet
  availability_zone = data.aws_availability_zones.primary.names[0]
  
  tags = {
    Name = "primary-subnet"
  }

  map_public_ip_on_launch = true
}

resource "aws_subnet" "secondary_subnet" {
  provider   = aws.secondary
  vpc_id     = aws_vpc.secondary.id
  cidr_block = var.secondary_subnet
  availability_zone = data.aws_availability_zones.secondary.names[0]

  tags = {
    Name = "secondary-subnet"
  }

  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "primary_igw" {
  provider = aws.primary
  vpc_id = aws_vpc.primary.id

  tags = {
    Name = "primary_igw"
  }
}

resource "aws_internet_gateway" "secondary_igw" {
  provider = aws.secondary
  vpc_id = aws_vpc.secondary.id

  tags = {
    Name = "secondary_igw"
  }
}

resource "aws_route_table" "primary_rt" {
  provider = aws.primary
  vpc_id   = aws_vpc.primary.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }

  tags = {
    Name        = "Primary-Route-Table"
  }
}

resource "aws_route_table" "secondary_rt" {
  provider = aws.secondary
  vpc_id   = aws_vpc.secondary.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.secondary_igw.id
  }

  tags = {
    Name        = "Secondary-Route-Table"
  }
}

resource "aws_route_table_association" "primary_rta" {
  provider       = aws.primary
  subnet_id      = aws_subnet.primary_subnet.id
  route_table_id = aws_route_table.primary_rt.id
}

resource "aws_route_table_association" "secondary_rta" {
  provider       = aws.secondary
  subnet_id      = aws_subnet.secondary_subnet.id
  route_table_id = aws_route_table.secondary_rt.id
}

resource "aws_vpc_peering_connection" "primary_to_secondary" {
  provider = aws.primary
  vpc_id      = aws_vpc.primary.id
  peer_vpc_id = aws_vpc.secondary.id
  peer_region = var.secondary_region
  auto_accept = false

  tags = {
    Name = "Primary to Secondary Peering"
    Side = "Requester"
  }
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "p2s_accepter" {
  region                    = var.secondary_region
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id 
  auto_accept               = true

  tags = {
    Name = "Primary to Secondary peering accepter"
    Side = "Accepter"
  }
}

resource "aws_route" "primary_secondary_route_entry" {
  provider                  = aws.primary
  route_table_id            = aws_route_table.primary_rt.id
  destination_cidr_block    = var.secondary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.p2s_accepter]
}

resource "aws_route" "secondary_primary_route_entry" {
  provider                  = aws.secondary
  route_table_id            = aws_route_table.secondary_rt.id
  destination_cidr_block    = var.primary_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.primary_to_secondary.id

  depends_on = [aws_vpc_peering_connection_accepter.p2s_accepter]
}

resource "aws_security_group" "primary_sg" {
  provider    = aws.primary
  name        = "Primary_SG"
  description = "Security group for Primary - EC2"
  vpc_id      = aws_vpc.primary.id
  tags = {
    Name = "Primary_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_rule" {
  provider = aws.primary
  security_group_id = aws_security_group.primary_sg.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "ICMP_rule" {
  security_group_id = aws_security_group.primary_sg.id
  
  cidr_ipv4   = var.secondary_vpc_cidr
  from_port   = -1
  ip_protocol = "icmp"
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "All_traffic_from_secondary" {
  security_group_id = aws_security_group.primary_sg.id
  
  cidr_ipv4   = var.secondary_vpc_cidr
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}

resource "aws_vpc_security_group_egress_rule" "Outbound_traffic_from_primary" {
  security_group_id = aws_security_group.primary_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

 
resource "aws_security_group" "secondary_sg" {
  provider    = aws.secondary 
  name        = "Secondary_SG"
  description = "Security group for Secondary - EC2"
  vpc_id      = aws_vpc.secondary.id
  tags = {
    Name = "Secondary_SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_rule_secondary" {
  provider = aws.secondary
  security_group_id = aws_security_group.secondary_sg.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "ICMP_rule_secondary" {
  provider = aws.secondary
  security_group_id = aws_security_group.secondary_sg.id
  
  cidr_ipv4   = var.primary_vpc_cidr
  from_port   = -1
  ip_protocol = "icmp"
  to_port     = -1
}

resource "aws_vpc_security_group_ingress_rule" "All_traffic_from_primary" {
  provider = aws.secondary
  security_group_id = aws_security_group.secondary_sg.id
  
  cidr_ipv4   = var.primary_vpc_cidr
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}

resource "aws_vpc_security_group_egress_rule" "Outbound_traffic_from_secondary" {
  provider = aws.secondary
  security_group_id = aws_security_group.secondary_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


resource "aws_instance" "primary_ec2_instance" {
  provider      = aws.primary
  ami           = data.aws_ami.primary_ec2_ami.id 
  instance_type = var.ec2_type
  vpc_security_group_ids = [aws_security_group.primary_sg.id]
  subnet_id = aws_subnet.primary_subnet.id 

  user_data = local.primary_user_data

  tags = {
    Name = "Primary_EC2_instance"
  }

  depends_on = [aws_vpc_peering_connection_accepter.p2s_accepter]

}

resource "aws_instance" "secondary_ec2_instance" {
  provider      = aws.secondary
  ami           = data.aws_ami.secondary_ec2_ami.id
  instance_type = var.ec2_type
  vpc_security_group_ids = [aws_security_group.secondary_sg.id]
  subnet_id = aws_subnet.secondary_subnet.id
   
  user_data = local.secondary_user_data

  tags = {
    Name = "Secondary_EC2_instance"
  }

  depends_on = [aws_vpc_peering_connection_accepter.p2s_accepter]
}
