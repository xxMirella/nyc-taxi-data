resource "databricks_catalog" "nyc_taxi" {
  name          = "nyc_taxi_catalog"
  owner         = var.databricks_user_email
  comment       = "Catálogo dedicado para o pipeline NYC Taxi"
  force_destroy = true
}

resource "databricks_schema" "production" {
  catalog_name = databricks_catalog.nyc_taxi.name
  name         = "nyc_taxi_prod"
  owner        = var.databricks_user_email
}

resource "databricks_volume" "scripts" {
  catalog_name = databricks_schema.production.catalog_name
  schema_name  = databricks_schema.production.name
  name         = "pipeline_artifacts"
  volume_type  = "MANAGED"
  owner        = var.databricks_user_email
}