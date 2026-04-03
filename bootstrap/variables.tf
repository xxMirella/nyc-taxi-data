###############################################
# AWS CONFIG
###############################################

variable "aws_region" {
  description = "AWS region onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "aws_account_id" {
  description = "ID da conta AWS onde a infraestrutura será provisionada"
  type        = string
}

###############################################
# GITHUB CONFIG (OIDC)
###############################################

variable "github_repo" {
  description = "Repositório GitHub no formato org/repo"
  type        = string
}

variable "github_branch" {
  description = "Branch autorizada a assumir a role (ex: main)"
  type        = string
  default     = "main"
}

variable "github_environment" {
  description = "Environment do GitHub Actions (opcional, ex: production)"
  type        = string
  default     = ""
}

###############################################
# IAM ROLE CONFIG (DEPLOY ROLE)
###############################################

variable "deploy_role_name" {
  description = "Nome da role que o GitHub Actions irá assumir para rodar o Terraform"
  type        = string
  default     = "github-actions-terraform-role"
}

variable "deploy_role_policy_arn" {
  description = "ARN da policy anexada à role de deploy"
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}

###############################################
# TAGS PADRÃO
###############################################

variable "tags" {
  description = "Tags padrão para todos os recursos criados"
  type        = map(string)

  default = {
    Project     = "nyc-taxi-databricks"
    ManagedBy   = "terraform"
    Environment = "dev"
  }
}
