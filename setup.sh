#!/usr/bin/env bash
set -e

echo "==> Step 0: Verifying Google Cloud Authentication..."

# 1. Check if a user account is active. If not, trigger login.
ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)

if [ -z "$ACTIVE_ACCOUNT" ]; then
    echo "No active credentials found. Initiating login..."
    gcloud auth login --brief
    ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
fi

echo "Authenticated as: $ACTIVE_ACCOUNT"

# 2. Check or set GCP Project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null || true)

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "(unset)" ]; then
    PROJECT_NAME="gws-security-audit"
    PROJECT_ID="${PROJECT_NAME}-$RANDOM"
    echo "No active project selected. Creating new project: $PROJECT_ID..."
    gcloud projects create "$PROJECT_ID" --name="GWS Security Audit"
    gcloud config set project "$PROJECT_ID"
else
    echo "Using existing active project: $PROJECT_ID"
fi

# Configuration Variables
SA_NAME="gws-audit-sa"
KEY_FILE="gws-audit-sa-key.json"
SCOPES="https://www.googleapis.com/auth/admin.reports.audit.readonly,https://www.googleapis.com/auth/admin.directory.user.readonly,https://www.googleapis.com/auth/admin.directory.device.mobile.readonly,https://www.googleapis.com/auth/admin.directory.rolemanagement.readonly,https://www.googleapis.com/auth/gmail.readonly,https://www.googleapis.com/auth/drive.metadata.readonly,https://www.googleapis.com/auth/apps.alerts"

echo "==> Step 1: Enabling Required APIs..."
gcloud services enable \
    admin.googleapis.com \
    gmail.googleapis.com \
    drive.googleapis.com \
    appsalerts.googleapis.com \
    chromemanagement.googleapis.com

echo "==> Step 2: Provisioning Service Account..."
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

# Create service account if it does not already exist
if ! gcloud iam service-accounts describe "$SA_EMAIL" >/dev/null 2>&1; then
    gcloud iam service-accounts create "$SA_NAME" \
        --display-name="Google Workspace Audit Service Account"
fi

# Fetch the OAuth2 Client ID (uniqueId)
CLIENT_ID=$(gcloud iam service-accounts describe "$SA_EMAIL" --format="value(uniqueId)")

echo "==> Step 3: Generating Service Account Key..."
# Overwrite existing key if it exists, or create new
rm -f "$KEY_FILE"
gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SA_EMAIL"

echo ""
echo "================================================================="
echo "✅ Setup Complete! Key generated: $KEY_FILE"
echo "================================================================="
echo ""
echo "👉 FINAL MANUAL STEP: Authorize Domain-Wide Delegation in Admin Console"
echo "1. Open: https://admin.google.com/ac/owl/domainwidedelegation"
echo "2. Click 'Add new'"
echo "3. Client ID (paste this exact number):"
echo "   $CLIENT_ID"
echo ""
echo "4. OAuth Scopes (copy and paste as a single line):"
echo "   $SCOPES"
echo ""
echo "5. Click 'Authorize'"
echo "================================================================="
echo ""
echo "To download the key to your computer for Colab, run:"
echo "cloudshell download $KEY_FILE"
echo "================================================================="
