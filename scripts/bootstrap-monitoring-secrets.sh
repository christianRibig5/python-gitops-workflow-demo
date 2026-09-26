#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Python GitOps Workflow Demo
# Monitoring Secrets Bootstrap
#
# Purpose:
#   Safely initialize runtime secrets after Terraform creates
#   the AWS Secrets Manager secret containers.
#
# Security:
#   - Secrets are never printed
#   - Secrets are never written to disk
#   - Existing AWSCURRENT values are preserved
#   - Sensitive shell variables are unset on exit
# ============================================================

AWS_PROFILE="${AWS_PROFILE:-dev-admin}"
AWS_REGION="${AWS_REGION:-ca-central-1}"

GRAFANA_SECRET="dev/monitoring/grafana/admin-password"
ALERTMANAGER_SECRET="dev/monitoring/alertmanager/zoho-smtp-password"
PROMETHEUS_GRAFANA_CLOUD_SECRET="dev/monitoring/prometheus/grafana-cloud-token"


# ============================================================
# Cleanup
# ============================================================

cleanup() {
    unset GRAFANA_PASSWORD 2>/dev/null || true
    unset ZOHO_PASSWORD 2>/dev/null || true
    unset GRAFANA_CLOUD_TOKEN 2>/dev/null || true
}

trap cleanup EXIT


# ============================================================
# Helper Functions
# ============================================================

secret_exists() {
    aws secretsmanager describe-secret \
        --secret-id "$1" \
        --region "$AWS_REGION" \
        --profile "$AWS_PROFILE" \
        >/dev/null 2>&1
}


secret_has_current_value() {
    aws secretsmanager get-secret-value \
        --secret-id "$1" \
        --version-stage AWSCURRENT \
        --region "$AWS_REGION" \
        --profile "$AWS_PROFILE" \
        >/dev/null 2>&1
}


echo "============================================================"
echo " Monitoring Secrets Bootstrap"
echo "============================================================"
echo
echo "AWS profile : $AWS_PROFILE"
echo "AWS region  : $AWS_REGION"
echo


# ============================================================
# Grafana Admin Password
# ============================================================

echo "Checking Grafana admin secret..."

if ! secret_exists "$GRAFANA_SECRET"; then
    echo "ERROR: Grafana secret container does not exist."
    echo "Run project Terraform first."
    exit 1
fi

if secret_has_current_value "$GRAFANA_SECRET"; then
    echo "Grafana secret already has AWSCURRENT. No change required."
else
    echo "Grafana secret has no AWSCURRENT value."
    echo "Generating secure Grafana admin password..."

    GRAFANA_PASSWORD="$(openssl rand -base64 32 | tr -d '\n')"

    aws secretsmanager put-secret-value \
        --secret-id "$GRAFANA_SECRET" \
        --secret-string "$GRAFANA_PASSWORD" \
        --region "$AWS_REGION" \
        --profile "$AWS_PROFILE" \
        >/dev/null

    unset GRAFANA_PASSWORD

    echo "Grafana admin password stored securely in AWS Secrets Manager."
fi

echo


# ============================================================
# Alertmanager Zoho SMTP Password
# ============================================================

echo "Checking Alertmanager Zoho SMTP secret..."

if ! secret_exists "$ALERTMANAGER_SECRET"; then
    echo "ERROR: Alertmanager secret container does not exist."
    echo "Run project Terraform first."
    exit 1
fi

if secret_has_current_value "$ALERTMANAGER_SECRET"; then
    echo "Alertmanager secret already has AWSCURRENT. No change required."
else
    echo "Alertmanager secret has no AWSCURRENT value."
    echo
    echo "Enter the Zoho SMTP/app password."
    echo "Input will be hidden."

    read -r -s -p "Zoho SMTP password: " ZOHO_PASSWORD
    echo

    if [[ -z "$ZOHO_PASSWORD" ]]; then
        echo "ERROR: Password cannot be empty."
        exit 1
    fi

    aws secretsmanager put-secret-value \
        --secret-id "$ALERTMANAGER_SECRET" \
        --secret-string "$ZOHO_PASSWORD" \
        --region "$AWS_REGION" \
        --profile "$AWS_PROFILE" \
        >/dev/null

    unset ZOHO_PASSWORD

    echo "Alertmanager Zoho password stored securely in AWS Secrets Manager."
fi

echo


# ============================================================
# Prometheus Grafana Cloud Token
# ============================================================

echo "Checking Prometheus Grafana Cloud secret..."

if ! secret_exists "$PROMETHEUS_GRAFANA_CLOUD_SECRET"; then
    echo "ERROR: Prometheus Grafana Cloud secret container does not exist."
    echo "Run the prometheus-grafana-cloud-secret Terraform component first."
    exit 1
fi

if secret_has_current_value "$PROMETHEUS_GRAFANA_CLOUD_SECRET"; then
    echo "Prometheus Grafana Cloud secret already has AWSCURRENT."
    echo "No change required."
else
    echo "Prometheus Grafana Cloud secret has no AWSCURRENT value."
    echo
    echo "Enter the Grafana Cloud access token used by Prometheus remote_write."
    echo "Input will be hidden."

    read -r -s -p "Grafana Cloud token: " GRAFANA_CLOUD_TOKEN
    echo

    if [[ -z "$GRAFANA_CLOUD_TOKEN" ]]; then
        echo "ERROR: Grafana Cloud token cannot be empty."
        exit 1
    fi

    aws secretsmanager put-secret-value \
        --secret-id "$PROMETHEUS_GRAFANA_CLOUD_SECRET" \
        --secret-string "$GRAFANA_CLOUD_TOKEN" \
        --region "$AWS_REGION" \
        --profile "$AWS_PROFILE" \
        >/dev/null

    unset GRAFANA_CLOUD_TOKEN

    echo "Prometheus Grafana Cloud token stored securely in AWS Secrets Manager."
fi

echo


# ============================================================
# Verification
# ============================================================

echo "Verifying secret versions..."

for SECRET_NAME in \
    "$GRAFANA_SECRET" \
    "$ALERTMANAGER_SECRET" \
    "$PROMETHEUS_GRAFANA_CLOUD_SECRET"
do
    if secret_has_current_value "$SECRET_NAME"; then
        echo "OK: $SECRET_NAME has AWSCURRENT"
    else
        echo "ERROR: $SECRET_NAME has no AWSCURRENT"
        exit 1
    fi
done

echo
echo "============================================================"
echo " Monitoring secrets are ready."
echo "============================================================"