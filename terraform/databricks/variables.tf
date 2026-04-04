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

variable "databricks_role_arn" {
  type = string
}

variable "enable_databricks_storage" {
  type    = bool
  default = false
}