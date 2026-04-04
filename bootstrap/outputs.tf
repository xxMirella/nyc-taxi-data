output "github_actions_role_arn" {
  description = "ARN da role que o GitHub Actions deve assumir via OIDC"
  value       = aws_iam_role.github_actions_deploy_role.arn
}

output "github_oidc_provider_arn" {
  description = "ARN do provider OIDC do GitHub"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_name" {
  description = "Nome da role criada para o GitHub Actions"
  value       = aws_iam_role.github_actions_deploy_role.name
}

output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}
