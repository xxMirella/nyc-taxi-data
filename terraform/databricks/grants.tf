locals {
  create_databricks_storage = var.enable_databricks_storage && trimspace(var.databricks_external_id) != ""
}

resource "databricks_storage_credential" "bronze_credential" {
  count = local.create_databricks_storage ? 1 : 0

  name = var.storage_credential_name

  aws_iam_role {
    role_arn = var.databricks_role_arn
  }
  comment = "Storage credential for bronze S3 location"
}

resource "databricks_external_location" "bronze_location" {
  count = local.create_databricks_storage ? 1 : 0

  name            = var.external_location_name
  url             = "s3://${var.bucket_name}/${var.bronze_prefix}"
  credential_name = databricks_storage_credential.bronze_credential[0].name
  comment         = "External location for bronze layer"
}

resource "databricks_grant" "catalog_use" {
  catalog    = "workspace"
  principal  = var.databricks_user_email
  privileges = ["USE_CATALOG"]
}

resource "databricks_grant" "schema_use" {
  schema     = databricks_schema.production.id
  principal  = var.databricks_user_email
  privileges = ["USE_SCHEMA"]
}

resource "databricks_grant" "volume_read" {
  volume     = databricks_volume.scripts.id
  principal  = var.databricks_user_email
  privileges = ["READ_VOLUME"]
}