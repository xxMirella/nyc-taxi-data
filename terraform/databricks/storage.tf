# resource "databricks_storage_credential" "bronze_credential" {
#   name = var.storage_credential_name
#
#   aws_iam_role {
#     role_arn = aws_iam_role.databricks_s3_role.arn
#   }
#
#   comment = "Storage credential for NYC Taxi bronze layer"
# }
#
# resource "databricks_external_location" "bronze_location" {
#   name            = var.external_location_name
#   url             = "s3://${var.bucket_name}/${var.bronze_prefix}"
#   credential_name = databricks_storage_credential.bronze_credential.name
#   comment         = "External location for NYC Taxi bronze layer"
# }