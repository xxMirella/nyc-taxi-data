resource "databricks_schema" "production" {
  catalog_name = "workspace"
  name         = "nyc_taxi_prod"
  owner        = var.databricks_user_email
  comment      = "Schema para o pipeline de produção"
}

resource "databricks_volume" "scripts" {
  catalog_name = databricks_schema.production.catalog_name
  schema_name  = databricks_schema.production.name
  name         = "pipeline_artifacts"
  volume_type  = "MANAGED"
  comment      = "Volume para armazenar scripts Python e arquivos .whl"
  owner        = var.databricks_user_email
}