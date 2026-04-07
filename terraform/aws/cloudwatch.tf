resource "aws_cloudwatch_log_group" "databricks_jobs" {
  name              = "/databricks/jobs/nyc-taxi"
  retention_in_days = 7
}