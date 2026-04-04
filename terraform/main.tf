module "aws" {
  source = "./aws"

  aws_account_id           = var.aws_account_id
  bucket_name              = var.bucket_name
  bronze_prefix            = var.bronze_prefix
  role_name                = var.role_name
  policy_name              = var.policy_name
  databricks_principal_arn = var.databricks_principal_arn
  databricks_external_id   = var.databricks_external_id
}

module "databricks" {
  source = "./databricks"

  bucket_name               = var.bucket_name
  bronze_prefix             = var.bronze_prefix
  storage_credential_name   = var.storage_credential_name
  external_location_name    = var.external_location_name
  databricks_group_name     = var.databricks_group_name
  databricks_role_arn       = module.aws.databricks_role_arn
  enable_databricks_storage = var.enable_databricks_storage

  depends_on = [module.aws]
}