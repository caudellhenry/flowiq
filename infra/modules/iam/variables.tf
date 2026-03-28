variable "env" {
  description = "Environment name"
  type        = string
}

variable "documents_bucket_arn" {
  description = "S3 documents bucket ARN"
  type        = string
}

variable "ecr_repository_arns" {
  description = "Map of ECR repository ARNs"
  type        = map(string)
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
