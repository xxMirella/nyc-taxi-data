variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "databricks_host" {
  description = "Databricks workspace URL"
  type        = string
}

variable "databricks_token" {
  description = "Databricks PAT token"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "55-taxi-data"
}

variable "bronze_prefix" {
  description = "Prefix for bronze layer in S3"
  type        = string
  default     = "nyc_taxi/bronze"
}

variable "role_name" {
  description = "IAM role name for Databricks access"
  type        = string
  default     = "databricks-nyc-taxi-bronze-role"
}

variable "policy_name" {
  description = "IAM policy name for Databricks S3 access"
  type        = string
  default     = "databricks-nyc-taxi-bronze-policy"
}

variable "storage_credential_name" {
  description = "Databricks storage credential name"
  type        = string
  default     = "nyc_taxi_bronze_credential"
}

variable "external_location_name" {
  description = "Databricks external location name"
  type        = string
  default     = "nyc_taxi_bronze_location"
}

variable "databricks_principal_arn" {
  description = "Databricks AWS principal ARN used to assume the role"
  type        = string
}

variable "databricks_external_id" {
  description = "External ID used in the trust relationship"
  type        = string
}

variable "databricks_group_name" {
  description = "Databricks group that will receive privileges"
  type        = string
  default     = "data-engineering"
}