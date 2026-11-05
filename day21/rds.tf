resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [for subnet in aws_subnet.dbtier_subnet : subnet.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_parameter_group" "my_db_parameter_group" {
  name_prefix = "my-db-parameter-group"
  family      = "postgres18"

  parameter {
    name  = "log_connections"
    value = "all"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "postgres_instance" {
  allocated_storage          = 20
  auto_minor_version_upgrade = false
  db_subnet_group_name       = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name       = aws_db_parameter_group.my_db_parameter_group.name

  vpc_security_group_ids = [aws_security_group.dbtier_ec2_sg.id]

  publicly_accessible = false

  engine                      = "postgres"
  engine_version              = "18.3"
  identifier                  = "postgres-instance"
  instance_class              = "db.t4g.micro"
  maintenance_window          = "Mon:00:00-Mon:03:00"
  multi_az                    = false
  storage_encrypted           = true
  manage_master_user_password = true
  skip_final_snapshot         = true

  db_name  = "goalsdb"
  username = "postgres"
  port     = 5432

  timeouts {
    create = "3h"
    delete = "3h"
    update = "3h"
  }
}