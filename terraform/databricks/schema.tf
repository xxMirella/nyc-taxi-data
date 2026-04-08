resource "databricks_external_location" "root_location" {
  count           = local.create_databricks_storage ? 1 : 0
  name            = "s3_root_location"
  url             = "s3://${var.bucket_name}/landing/nyc_taxi_catalog/"
  credential_name = one(databricks_storage_credential.bronze_credential[*].name)
  comment         = "Permite ao Unity Catalog gerenciar todo o bucket"
  depends_on      = [var.aws_setup_completed]
}

resource "databricks_catalog" "nyc_taxi" {
  name          = var.catalog_name
  owner         = var.databricks_user_email
  storage_root  = "s3://${var.bucket_name}/landing/${var.catalog_name}"
  comment       = "Catálogo dedicado para o pipeline NYC Taxi"
  force_destroy = true
  depends_on    = [databricks_external_location.root_location]
}

resource "databricks_schema" "production" {
  catalog_name = databricks_catalog.nyc_taxi.name
  name         = var.schema_name
  owner        = var.databricks_user_email
  storage_root = "s3://${var.bucket_name}/landing/${var.catalog_name}/${var.schema_name}/"
  depends_on   = [databricks_catalog.nyc_taxi]
}

resource "databricks_volume" "scripts" {
  catalog_name = databricks_schema.production.catalog_name
  schema_name  = databricks_schema.production.name
  name         = "pipeline_artifacts"
  volume_type  = "MANAGED"
  owner        = var.databricks_user_email
}

resource "databricks_external_location" "uc_volumes_root" {
  name            = "${var.schema_name}_uc_volumes_root"
  url             = "s3://${var.bucket_name}/uc-volumes/"
  credential_name = var.storage_credential_name
  comment         = "Root external location for operational Unity Catalog volumes"
}

resource "databricks_volume" "landing" {
  name             = "landing"
  catalog_name     = var.catalog_name
  schema_name      = var.schema_name
  volume_type      = "EXTERNAL"
  storage_location = "s3://${var.bucket_name}/uc-volumes/landing"
  comment          = "Landing files for NYC Taxi ingestion"

  depends_on = [databricks_external_location.uc_volumes_root]
}

resource "databricks_volume" "checkpoints" {
  name             = "checkpoints"
  catalog_name     = var.catalog_name
  schema_name      = var.schema_name
  volume_type      = "EXTERNAL"
  storage_location = "s3://${var.bucket_name}/uc-volumes/checkpoints"
  comment          = "Checkpoint files for Auto Loader and streaming"

  depends_on = [databricks_external_location.uc_volumes_root]
}
