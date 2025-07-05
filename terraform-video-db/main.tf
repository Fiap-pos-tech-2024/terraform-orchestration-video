terraform {
  backend "s3" {
    bucket = "terraform-states-816069165502"
    key    = "video-db/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-states-816069165502"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Subnet group para o RDS dentro da VPC
resource "aws_db_subnet_group" "video" {
  name        = "video-db-subnet-group"
  subnet_ids  = data.terraform_remote_state.network.outputs.public_subnet_ids
  description = "Subnet group for video RDS"
}

# Security Group que abre 3306 para todo trafego (apenas para testes)
resource "aws_security_group" "video_db_sg" {
  name        = "video-db-sg"
  description = "Allow MySQL 3306 from anywhere"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

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
resource "aws_db_instance" "video" {
  identifier             = "video-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name

  db_subnet_group_name   = aws_db_subnet_group.video.name
  vpc_security_group_ids = [aws_security_group.video_db_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
}
