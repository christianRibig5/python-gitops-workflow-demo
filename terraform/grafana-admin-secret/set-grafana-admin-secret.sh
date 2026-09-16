#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ca-central-1}"
AWS_PROFILE="${AWS_PROFILE:-dev-admin}"
SECRET_ID="${1:-dev/monitoring/grafana/admin-password}"

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

# Terraform must create the secret container before this script runs.
if ! aws secretsmanager describe-secret \
  --secret-id "${SECRET_ID}" \
  --region "${AWS_REGION}" \
  --profile "${AWS_PROFILE}" \
  >/dev/null 2>&1; then
  echo "Error: Secret '${SECRET_ID}' does not exist or is inaccessible."
  echo "Check your AWS profile and run Terraform secret creation first."
  exit 1
fi

# Limit access to the temporary password file and remove it on exit.
umask 077
SECRET_FILE="$(mktemp)"

cleanup() {
  rm -f "${SECRET_FILE}"
  unset GRAFANA_ADMIN_PASSWORD
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

read -r -s -p "Enter the Grafana admin password: " GRAFANA_ADMIN_PASSWORD
echo

if [[ -z "${GRAFANA_ADMIN_PASSWORD}" ]]; then
  echo "Error: Password cannot be empty."
  exit 1
fi

printf '%s' "${GRAFANA_ADMIN_PASSWORD}" > "${SECRET_FILE}"
chmod 600 "${SECRET_FILE}"
unset GRAFANA_ADMIN_PASSWORD

echo "Uploading Grafana admin password to AWS Secrets Manager..."

aws secretsmanager put-secret-value \
  --secret-id "${SECRET_ID}" \
  --secret-string "file://${SECRET_FILE}" \
  --region "${AWS_REGION}" \
  --profile "${AWS_PROFILE}" \
  --query '{ARN:ARN,Name:Name,VersionId:VersionId}' \
  --output table

echo "Grafana admin password uploaded successfully."
echo "The temporary password file has been removed."