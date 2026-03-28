output "alb_dns_name" {
  description = "ALB DNS name — point your staging domain here"
  value       = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.endpoint
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = module.redis.endpoint
}

output "redis_connection_url" {
  description = "Redis connection URL"
  value       = module.redis.connection_url
}

output "s3_documents_bucket" {
  description = "S3 documents bucket name"
  value       = module.s3.documents_bucket_name
}

output "ecr_repository_urls" {
  description = "ECR repository URLs per service"
  value       = module.ecr.repository_urls
}

output "github_actions_deploy_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC deploy"
  value       = module.iam.github_actions_deploy_role_arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}
