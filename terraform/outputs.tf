output "bucket_name" {
  value = aws_s3_bucket.taxi_data.bucket
}

output "iam_role_arn" {
  value = aws_iam_role.databricks_s3_role.arn
}

output "storage_credential_name" {
  value = databricks_storage_credential.bronze_credential.name
}

output "external_location_name" {
  value = databricks_external_location.bronze_location.name
}

output "external_location_url" {
  value = databricks_external_location.bronze_location.url
}