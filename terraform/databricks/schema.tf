resource "databricks_external_location" "root_location" {
  count           = local.create_databricks_storage ? 1 : 0
  name            = "s3_root_location"
  url             = "s3://${var.bucket_name}/landing/nyc_taxi_catalog/"
  credential_name = one(databricks_storage_credential.bronze_credential[*].name)
  comment         = "Permite ao Unity Catalog gerenciar todo o bucket"
  depends_on      = [var.aws_setup_completed]
}

resource "databricks_catalog" "nyc_taxi" {
  name          = "nyc_taxi_catalog"
  owner         = var.databricks_user_email
  comment       = "Catálogo dedicado para o pipeline NYC Taxi"
  force_destroy = true
  depends_on    = [databricks_external_location.root_location]
}

resource "databricks_schema" "production" {
  catalog_name = databricks_catalog.nyc_taxi.name
  name         = "nyc_taxi_prod"
  owner        = var.databricks_user_email
  storage_root = "s3://${var.bucket_name}/landing/nyc_taxi_catalog/nyc_taxi_prod/"
  depends_on   = [databricks_catalog.nyc_taxi]
}

resource "databricks_volume" "scripts" {
  catalog_name = databricks_schema.production.catalog_name
  schema_name  = databricks_schema.production.name
  name         = "pipeline_artifacts"
  volume_type  = "MANAGED"
  owner        = var.databricks_user_email
}