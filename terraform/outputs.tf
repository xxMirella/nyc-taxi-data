output "bucket_name" {
  value = module.aws.bucket_name
}

output "iam_role_arn" {
  value = module.aws.databricks_role_arn
}

output "storage_credential_name" {
  value = module.databricks.storage_credential_name
}

output "external_location_name" {
  value = module.databricks.external_location_name
}

output "external_location_url" {
  value = module.databricks.external_location_url
}