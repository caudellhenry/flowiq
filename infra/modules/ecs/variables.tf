variable "env" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "api_task_role_arn" {
  description = "IAM role ARN for api task"
  type        = string
}

variable "web_task_role_arn" {
  description = "IAM role ARN for web task"
  type        = string
}

variable "ai_service_task_role_arn" {
  description = "IAM role ARN for ai-service task"
  type        = string
}

variable "api_image" {
  description = "ECR image URI for api service"
  type        = string
}

variable "web_image" {
  description = "ECR image URI for web service"
  type        = string
}

variable "ai_service_image" {
  description = "ECR image URI for ai-service"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
