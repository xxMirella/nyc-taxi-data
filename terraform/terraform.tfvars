aws_region                = "us-east-1"
aws_account_id            = "123456789012"
databricks_host           = "https://dbc-0e973db6-772a.cloud.databricks.com/"
databricks_token          = "coloque_seu_token_aqui"

bucket_name               = "55-taxi-data"
bronze_prefix             = "nyc_taxi/bronze"

role_name                 = "databricks-nyc-taxi-bronze-role"
policy_name               = "databricks-nyc-taxi-bronze-policy"

storage_credential_name   = "nyc_taxi_bronze_credential"
external_location_name    = "nyc_taxi_bronze_location"

databricks_principal_arn  = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-ABC123"
databricks_external_id    = "external-id-gerado-ou-definido-no-seu-processo"
databricks_group_name     = "data-engineering"


github_repo               = "mirella-souza/nyc-taxi-databricks"
github_branch             = "main"
github_environment        = ""
deploy_role_name          = "github-actions-terraform-role"