variable "env" {
  description = "Environment name"
  type        = string
}

variable "services" {
  description = "List of service names to create ECR repos for"
  type        = list(string)
  default     = ["api", "web", "ai-service"]
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
