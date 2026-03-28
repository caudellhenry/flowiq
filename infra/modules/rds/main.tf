resource "aws_security_group" "rds" {
  name        = "flowiq-${var.env}-rds-sg"
  description = "RDS PostgreSQL security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "flowiq-${var.env}-rds-sg" })
}

resource "aws_db_subnet_group" "main" {
  name       = "flowiq-${var.env}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "flowiq-${var.env}-rds-subnet-group" })
}

resource "aws_db_parameter_group" "postgres" {
  name   = "flowiq-${var.env}-pg15"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = var.tags
}

resource "aws_db_instance" "main" {
  identifier     = "flowiq-${var.env}"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  multi_az               = false  # Off for staging
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name
  publicly_accessible    = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection      = false  # Allows clean teardown in staging
  skip_final_snapshot      = true
  delete_automated_backups = true

  tags = merge(var.tags, { Name = "flowiq-${var.env}-rds" })
}
