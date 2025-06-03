provider "aws" {
  region = var.aws_region
}

# Subnet group para o RDS dentro da VPC
resource "aws_db_subnet_group" "cliente" {
  name        = "cliente-db-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group for Cliente RDS"
}

# Security Group que abre 3306 para todo trafego (apenas para testes)
resource "aws_security_group" "cliente_db_sg" {
  name        = "cliente-db-sg"
  description = "Allow MySQL 3306 from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instancia RDS MySQL publica
resource "aws_db_instance" "cliente" {
  identifier             = "cliente-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name

  db_subnet_group_name   = aws_db_subnet_group.cliente.name
  vpc_security_group_ids = [aws_security_group.cliente_db_sg.id]

  publicly_accessible = true
  skip_final_snapshot = true
}
