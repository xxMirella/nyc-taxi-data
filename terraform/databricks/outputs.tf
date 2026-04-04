output "storage_credential_name" {
  value = var.enable_databricks_storage ? databricks_storage_credential.bronze_credential[0].name : null
}

output "external_location_name" {
  value = var.enable_databricks_storage ? databricks_external_location.bronze_location[0].name : null
}

output "external_location_url" {
  value = var.enable_databricks_storage ? databricks_external_location.bronze_location[0].url : null
}