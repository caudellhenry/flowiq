output "documents_bucket_name" {
  description = "S3 documents bucket name"
  value       = aws_s3_bucket.documents.id
}

output "documents_bucket_arn" {
  description = "S3 documents bucket ARN"
  value       = aws_s3_bucket.documents.arn
}
