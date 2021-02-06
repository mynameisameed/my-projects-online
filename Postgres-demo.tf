# https://www.terraform.io/docs/providers/aws/r/db_instance.html

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "random_string" "uddin-db-password" {
  length  = 32
  upper   = true
  number  = true
  special = false
}

resource "aws_security_group" "uddin" {
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "uddin"
  description = "Allow all inbound for Postgres"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "uddin-sameed" {
  identifier             = "uddin-sameed"
  name                   = "uddin"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.5"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.uddin.id]
  username               = "sameed"
  password               = "random_string.uddin-db-password.result}"

  # Backups are required in order to create a replica
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 1
}

resource "aws_db_instance" "uddin-sameed-read" {
  identifier             = "uddin-sameed-read"
  replicate_source_db    = aws_db_instance.uddin-sameed.identifier ## refer to the master instance
  name                   = "uddin"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12.5"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.uddin.id]

  # Username and password must not be set for replicas
  username = ""
  password = ""

  # disable backups to create DB faster
  backup_retention_period = 0
}