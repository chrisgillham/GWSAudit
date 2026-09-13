#!/usr/bin/env bash
set -e

PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID="gws-security-audit-$RANDOM"
  echo "==> Creating new GCP project: $PROJECT_ID..."
  gcloud projects create "$PROJECT_ID" --name="GWS Security Audit"
  gcloud config set project "$PROJECT_ID"
fi

echo "==> Enabling required APIs..."
gcloud services enable \
  admin.googleapis.com \
  gmail.googleapis.com \
  drive.googleapis.com \
  appsalerts.googleapis.com \
  chromemanagement.googleapis.com

echo "==> Creating Service Account..."
gcloud iam service-accounts create gws-audit-sa \
  --display-name="Google Workspace Audit Service Account" || true

SA_EMAIL="gws-audit-sa@${PROJECT_ID}.iam.gserviceaccount.com"

echo "==> Generating Service Account JSON Key..."
gcloud iam service-accounts keys create gws-audit-sa-key.json \
  --iam-account="$SA_EMAIL"

CLIENT_ID=$(gcloud iam service-accounts describe "$SA_EMAIL" --format="value(uniqueId)")

echo ""
echo "================================================================="
echo "Client ID for Domain-Wide Delegation:"
echo "$CLIENT_ID"
echo "================================================================="
