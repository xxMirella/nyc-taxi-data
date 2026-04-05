output "bucket_name" {
  value = aws_s3_bucket.taxi_data.bucket
}

output "databricks_role_arn" {
  value = length(aws_iam_role.databricks_s3_role) > 0 ? aws_iam_role.databricks_s3_role[0].arn : null
}