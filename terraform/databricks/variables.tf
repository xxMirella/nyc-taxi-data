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
  description = "Nome do Job no Databricks"
  type        = string
}

variable "databricks_run_as_service_principal" {
  description = "Application ID do service principal usado no run_as do job"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.databricks_run_as_service_principal))
    error_message = "databricks_run_as_service_principal deve ser o Application ID do service principal, no formato UUID, e não o nome amigável."
  }
}

variable "environment" {
  description = "Ambiente (dev/prod)"
  type        = string
}

variable "databricks_user_email" {
  description = "O e-mail do usuário que possui permissões e executará o Job"
  type        = string
}

variable "aws_setup_completed" {
  type        = any
  description = "Variável técnica para forçar a dependência entre AWS e Databricks"
  default     = null
}

variable "catalog_name" {
  type    = string
  default = "nyc_taxi_catalog"
}

variable "schema_name" {
  type    = string
  default = "nyc_taxi_prod"
}