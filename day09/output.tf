output "primary_vpc_id" {
  description = "Primary VPC ID"
  value = aws_vpc.primary.id
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID"
  value = aws_vpc.secondary.id
}

output "primary_vpc_CIDR" {
  description = "Primary VPC CIDR block"
  value = aws_vpc.primary.cidr_block
}

output "secondary_vpc_CIDR" {
  description = "Secondary VPC CIDR block"
  value = aws_vpc.secondary.cidr_block
}

output "primary_subnet" {
  description = "Subnet of Primary VPC"
  value = aws_subnet.primary_subnet.id
}

output "secondary_subnet" {
  description = "Subnet of Secondary VPC"
  value = aws_subnet.secondary_subnet.id
}

output "primary_igw" {
  description = "Primary Internet Gateway"
  value = aws_internet_gateway.primary_igw.id
}

output "secondary_igw" {
  description = "Secondary Internet Gateway"
  value = aws_internet_gateway.secondary_igw.id
}

output "route_table_primary"{
  description = "Primary Route table"
  value = aws_route_table.primary_rt.id
}

output "route_table_secondary"{
  description = "Secondary Route table"
  value = aws_route_table.secondary_rt.id
}

output "peering_status" {
  description = "Peering status"
  value = aws_vpc_peering_connection.primary_to_secondary.accept_status
}

output "primary_sg_ingress"{
    description = "Primary sg list ingress"
  value = aws_security_group.primary_sg.ingress
}

output "primary_sg_egress"{
    description = "Primary sg list egress"
  value = aws_security_group.primary_sg.egress
}