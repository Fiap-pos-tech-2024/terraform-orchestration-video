terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Subnet Group para o RDS ---
resource "aws_db_subnet_group" "pedido" {
  name        = "pedido-db-subnet-group"
  description = "Subnet group para Pedido RDS"
  subnet_ids  = var.subnet_ids
}

# --- Security Group abrindo MySQL 3306 para todo mundo (só p/ testes) ---
resource "aws_security_group" "pedido_db_sg" {
  name        = "pedido-db-sg"
  description = "Permite acesso MySQL 3306 de qualquer IP (teste)"
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

# --- Instância RDS MySQL pública ---
resource "aws_db_instance" "pedido" {
  identifier             = "pedido-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  vpc_security_group_ids = [aws_security_group.pedido_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.pedido.name

  publicly_accessible = true
  skip_final_snapshot = true
}
