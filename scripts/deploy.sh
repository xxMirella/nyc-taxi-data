#!/bin/bash
# Script para empacotar e subir o código para o S3 de artefatos
ENV=$1
BUCKET_ARTIFACTS="nyc-taxi-${ENV}-artifacts"

echo "Empacotando projeto para ambiente: $ENV"

# Sincroniza o código fonte com o S3
aws s3 sync ./src s3://${BUCKET_ARTIFACTS}/artifacts/ \
    --exclude "*.pyc" \
    --exclude "__pycache__/*"

# Dispara o Terraform para atualizar o Job se necessário
cd ../terraform
terraform init
terraform apply -var="environment=${ENV}" -auto-approve

echo "Deploy concluído!"