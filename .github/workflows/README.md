# Workflows de GitHub Actions

## Arquivos
- `terraform-ci.yml`: roda em `pull_request` e manualmente. Faz varredura de segredos, `terraform fmt`, `validate` e `plan`.
- `terraform-apply.yml`: roda em `push` para `main` e manualmente. Só aplica depois que a varredura de segredos e os checks de Terraform terminam com sucesso.

## Ordem de execução
No GitHub Actions, jobs rodam em paralelo por padrão. Aqui a ordem foi forçada com `needs`:
- `security_scan` -> `terraform_checks`
- `terraform_checks` -> `terraform_apply`

## Segredos e variáveis que você precisa criar no repositório

### Repository secrets
- `AWS_DEPLOY_ROLE_ARN`: ARN da role que o GitHub Actions vai assumir na AWS via OIDC.
- `DATABRICKS_TOKEN`: token do Databricks para o provider Terraform.

### Repository variables
- `AWS_REGION`
- `AWS_ACCOUNT_ID`
- `BUCKET_NAME`
- `BRONZE_PREFIX`
- `ROLE_NAME`
- `POLICY_NAME`
- `STORAGE_CREDENTIAL_NAME`
- `EXTERNAL_LOCATION_NAME`
- `DATABRICKS_HOST`
- `DATABRICKS_PRINCIPAL_ARN`
- `DATABRICKS_EXTERNAL_ID`
- `DATABRICKS_GROUP_NAME`

## OIDC na AWS
Esses workflows usam `aws-actions/configure-aws-credentials` com OIDC. Você precisa criar na AWS:
1. O provedor OIDC do GitHub.
2. Uma role para o GitHub Actions assumir.
3. A trust policy dessa role restringindo repositório, branch ou environment.

## Observações importantes
- Para `apply`, configure o environment `production` com aprovação manual no GitHub se quiser um gate antes da implantação.
- O ideal é usar backend remoto do Terraform. Sem isso, o `apply` roda com state local efêmero no runner.
- O workflow injeta as variáveis do Terraform com `TF_VAR_*`, então você não precisa versionar `terraform.tfvars`.
