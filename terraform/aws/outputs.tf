output "bucket_name" {
  value = aws_s3_bucket.taxi_data.bucket
}

output "databricks_role_arn" {
  value = aws_iam_role.databricks_s3_role.arn
}

output "databricks_s3_policy_arn" {
  value       = aws_iam_policy.databricks_s3_policy.arn
  description = "ARN da política S3 para garantir a ordem de criação"
}