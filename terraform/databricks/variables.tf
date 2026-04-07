variable "bucket_name" {
  type = string
}

variable "bronze_prefix" {
  type = string
}

variable "storage_credential_name" {
  type = string
}

variable "external_location_name" {
  type = string
}

variable "databricks_group_name" {
  type = string
}

variable "enable_databricks_storage" {
  type    = bool
  default = false
}

variable "databricks_external_id" {
  type    = string
  default = ""
}

variable "databricks_role_arn" {
  type    = string
  default = ""
}

variable "job_name" {
  type = string
}

variable "s3_code_path" {
  type = string
}