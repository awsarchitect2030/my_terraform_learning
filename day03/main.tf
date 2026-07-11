# Using data_types/type_constraints
resource "aws_instance" "example" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = var.Instance_type_list[1]
  count         = var.instance_count
  monitoring     = var.monitoring
  availability_zone = tolist(var.AZ_set)[1]

  tags = merge(var.tag_map,
    {
    Name = var.tag_name,
    Environment = var.Environment
    }
  )

}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_tls" {
  name        = var.sg_config_tag.Name
  description = var.sg_config_tag.description

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = data.aws_vpc.default.cidr_block
  from_port         = var.SG_config[0]
  ip_protocol       = var.SG_config[1]
  to_port           = var.SG_config[2]
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


