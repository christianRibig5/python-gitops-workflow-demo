#!/usr/bin/env bash

set -euo pipefail

AWS_REGION="${AWS_REGION:-ca-central-1}"
AWS_PROFILE="${AWS_PROFILE:-dev-admin}"
SECRET_ID="${1:-dev/monitoring/alertmanager/zoho-smtp-password}"

if ! command -v aws >/dev/null 2>&1; then
  echo "Error: AWS CLI is not installed."
  exit 1
fi

echo "AWS profile : ${AWS_PROFILE}"
echo "AWS region  : ${AWS_REGION}"
echo "Secret name : ${SECRET_ID}"

# Confirm AWS authentication.
aws sts get-caller-identity \
  --profile "${AWS_PROFILE}" \
  --query '{Account:Account,Arn:Arn}' \
  --output table

# Confirm that Terraform has already created the secret container.
if ! aws secretsmanager describe-secret \
  --secret-id "${SECRET_ID}" \
  --region "${AWS_REGION}" \
  --profile "${AWS_PROFILE}" \
  >/dev/null 2>&1; then

  echo "Error: Secret '${SECRET_ID}' does not exist."
  echo "Run the Terraform secret creation first."
  exit 1
fi

# Create a protected temporary file.
umask 077
SECRET_FILE="$(mktemp)"

cleanup() {
  rm -f "${SECRET_FILE}"
  unset ZOHO_APP_PASSWORD
}

trap cleanup EXIT INT TERM

read -r -s -p "Enter the Zoho application password: " ZOHO_APP_PASSWORD
echo

if [[ -z "${ZOHO_APP_PASSWORD}" ]]; then
  echo "Error: Password cannot be empty."
  exit 1
fi

printf '%s' "${ZOHO_APP_PASSWORD}" > "${SECRET_FILE}"
chmod 600 "${SECRET_FILE}"

echo "Uploading password to AWS Secrets Manager..."

aws secretsmanager put-secret-value \
  --secret-id "${SECRET_ID}" \
  --secret-string "file://${SECRET_FILE}" \
  --region "${AWS_REGION}" \
  --profile "${AWS_PROFILE}" \
  --query '{ARN:ARN,Name:Name,VersionId:VersionId}' \
  --output table

echo "Zoho SMTP password uploaded successfully."
echo "The temporary password file has been removed."