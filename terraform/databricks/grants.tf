locals {
  create_databricks_storage = var.enable_databricks_storage && try(trimspace(var.databricks_role_arn), "") != ""
}

resource "databricks_storage_credential" "bronze_credential" {
  count = local.create_databricks_storage ? 1 : 0

  name = var.storage_credential_name

  aws_iam_role {
    role_arn = var.databricks_role_arn
  }

  comment = "Storage credential for NYC Taxi bronze layer"
}

resource "databricks_external_location" "bronze_location" {
  count = local.create_databricks_storage ? 1 : 0

  name            = var.external_location_name
  url             = "s3://${var.bucket_name}/${var.bronze_prefix}"
  credential_name = databricks_storage_credential.bronze_credential[0].name
  comment         = "External location for NYC Taxi bronze layer"
}
