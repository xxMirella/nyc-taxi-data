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

  depends_on = [databricks_storage_credential.bronze_credential]
}

resource "databricks_grants" "catalog_grants" {
  catalog = var.catalog_name

  grant {
    principal  = var.databricks_run_as_service_principal
    privileges = ["USE_CATALOG"]
  }

  grant {
    principal  = var.databricks_user_email
    privileges = ["USE_CATALOG"]
  }

  depends_on = [databricks_catalog.nyc_taxi]
}

resource "databricks_grants" "schema_grants" {
  schema = "${var.catalog_name}.${var.schema_name}"

  grant {
    principal = var.databricks_run_as_service_principal
    privileges = [
      "USE_SCHEMA",
      "CREATE_TABLE",
      "CREATE_VOLUME",
      "READ_VOLUME",
      "WRITE_VOLUME"
    ]
  }

  grant {
    principal = var.databricks_user_email
    privileges = [
      "USE_SCHEMA",
      "READ_VOLUME",
      "WRITE_VOLUME"
    ]
  }

  depends_on = [
    databricks_catalog.nyc_taxi,
    databricks_schema.production
  ]
}

resource "databricks_grants" "landing_volume" {
  volume = "${var.catalog_name}.${var.schema_name}.${databricks_volume.landing.name}"

  grant {
    principal  = var.databricks_run_as_service_principal
    privileges = ["READ_VOLUME", "WRITE_VOLUME"]
  }

  grant {
    principal  = var.databricks_user_email
    privileges = ["READ_VOLUME", "WRITE_VOLUME"]
  }

  depends_on = [databricks_volume.landing]
}

resource "databricks_grants" "checkpoints_volume" {
  volume = "${var.catalog_name}.${var.schema_name}.${databricks_volume.checkpoints.name}"

  grant {
    principal  = var.databricks_run_as_service_principal
    privileges = ["READ_VOLUME", "WRITE_VOLUME"]
  }

  grant {
    principal  = var.databricks_user_email
    privileges = ["READ_VOLUME", "WRITE_VOLUME"]
  }

  depends_on = [databricks_volume.checkpoints]
}

resource "databricks_grants" "uc_volumes_root" {
  external_location = databricks_external_location.uc_volumes_root.id

  grant {
    principal  = var.databricks_run_as_service_principal
    privileges = ["CREATE_EXTERNAL_VOLUME", "READ_FILES", "WRITE_FILES"]
  }

  grant {
    principal  = var.databricks_user_email
    privileges = ["READ_FILES", "WRITE_FILES"]
  }

  depends_on = [databricks_external_location.uc_volumes_root]
}