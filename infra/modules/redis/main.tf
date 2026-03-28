resource "aws_security_group" "redis" {
  name        = "flowiq-${var.env}-redis-sg"
  description = "ElastiCache Redis security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "flowiq-${var.env}-redis-sg" })
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "flowiq-${var.env}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = var.tags
}

resource "aws_elasticache_parameter_group" "redis7" {
  name   = "flowiq-${var.env}-redis7"
  family = "redis7"

  tags = var.tags
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "flowiq-${var.env}"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = var.node_type
  num_cache_nodes      = 1  # Single node for staging
  parameter_group_name = aws_elasticache_parameter_group.redis7.name
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  snapshot_retention_limit = 1
  snapshot_window          = "05:00-06:00"

  tags = merge(var.tags, { Name = "flowiq-${var.env}-redis" })
}
