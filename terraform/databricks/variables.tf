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

variable "s3_code_path" {
  description = "Caminho completo do S3 onde o main.py está armazenado"
  type        = string
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