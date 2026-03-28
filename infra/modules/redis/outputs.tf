output "endpoint" {
  description = "Redis cache node endpoint"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.main.port
}

output "connection_url" {
  description = "Redis connection URL"
  value       = "redis://${aws_elasticache_cluster.main.cache_nodes[0].address}:${aws_elasticache_cluster.main.port}"
}

output "security_group_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis.id
}
