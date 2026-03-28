output "api_task_role_arn" {
  description = "API ECS task role ARN"
  value       = aws_iam_role.api_task.arn
}

output "web_task_role_arn" {
  description = "Web ECS task role ARN"
  value       = aws_iam_role.web_task.arn
}

output "ai_service_task_role_arn" {
  description = "AI service ECS task role ARN"
  value       = aws_iam_role.ai_service_task.arn
}

output "github_actions_deploy_role_arn" {
  description = "GitHub Actions deploy role ARN"
  value       = aws_iam_role.github_actions_deploy.arn
}
