aws_region       = "us-east-1"
aws_account_id   = ""
databricks_host  = "https://dbc-0e973db6-772a.cloud.databricks.com"
databricks_token = "coloque_seu_token_aqui"

bucket_name   = "55-taxi-data"
bronze_prefix = "nyc_taxi/bronze"

role_name   = "databricks-nyc-taxi-bronze-role"
policy_name = "databricks-nyc-taxi-bronze-policy"

storage_credential_name = "nyc_taxi_bronze_credential"
external_location_name  = "nyc_taxi_bronze_location"

databricks_principal_arn = ""
databricks_external_id   = ""
databricks_group_name    = "data-engineering"

enable_databricks_storage = false