#!/bin/bash
set -euo pipefail

CONFIG_PATH=../config.json
SERVICE_ACCOUNT_NAME=$(grep -oP '"terraform_username":\s*"\K[^"]+' "$CONFIG_PATH")
ROLE="roles/$1"
PROJECT_ID=$(gcloud config get-value project)
DESCRIPTION="The service account for the Terraform"
KEY_FILE=$2
BUCKET_NAME=$(grep -oP '"bucket_state_name":\s*"\K[^"]+' "$CONFIG_PATH")
BUCKET_LOCATION=$(grep -oP '"state_bucket_location_gcp":\s*"\K[^"]+' "$CONFIG_PATH")

if [[ -z "$PROJECT_ID" ]]; then
  echo "❌ Error: Unable to retrieve GCP project ID. Use 'gcloud config set project YOUR_PROJECT_ID'"
  exit 1
else
  echo "=== Project's id: '$PROJECT_ID' ==="
fi

REQUIRED_APIS=(
  "iamcredentials.googleapis.com"
  "compute.googleapis.com"
  "sqladmin.googleapis.com"
  "cloudresourcemanager.googleapis.com"
  "serviceusage.googleapis.com"
  "storage.googleapis.com"
)

echo "=== Enabling required APIs for project: $PROJECT_ID ==="
for api in "${REQUIRED_APIS[@]}"; do
  echo "- Enabling '$api'..."
  gcloud services enable "$api" --project="$PROJECT_ID" || echo "⚠️  Failed to enable $api"
done
echo "=== All required APIs attempted to enable. ==="
echo

# Check if service account exists
echo "=== Checking for service account $SERVICE_ACCOUNT_NAME... ==="
if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" &>/dev/null; then
  echo "ℹ️ Service account already exists: $SERVICE_ACCOUNT_NAME"
else
  echo "🆕 Creating service account: $SERVICE_ACCOUNT_NAME"
  gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
    --description="$DESCRIPTION" \
    --display-name="$SERVICE_ACCOUNT_NAME"
fi

# Assign role
echo "🔑 Binding role '$ROLE' to service account..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="$ROLE" || echo "⚠️ Role binding may already exist"

# Generate key only if it doesn't exist
# echo "=== Checking if key file already exists: $KEY_FILE ==="
# if [[ -f "$KEY_FILE" ]]; then
#   echo "ℹ️ Key file already exists: $KEY_FILE. Skipping creation."
# else
#   echo "🔐 Creating key file: $KEY_FILE"
#   gcloud iam service-accounts keys create "$KEY_FILE" \
#     --iam-account="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
# fi

# Create bucket if not exists
echo "=== Checking if bucket exists: gs://$BUCKET_NAME ==="
if gsutil ls -p "$PROJECT_ID" "gs://$BUCKET_NAME" &>/dev/null; then
  echo "ℹ️ Bucket already exists: gs://$BUCKET_NAME"
else
  echo "🪣 Creating bucket: gs://$BUCKET_NAME in $BUCKET_LOCATION"
  gcloud storage buckets create "gs://$BUCKET_NAME" \
    --location="$BUCKET_LOCATION" \
    --uniform-bucket-level-access
fi

# Enable versioning
echo "🔁 Enabling versioning on bucket: gs://$BUCKET_NAME"
gsutil versioning set on "gs://$BUCKET_NAME" || echo "⚠️ Versioning already enabled?"

# Terraform
echo "🚀 STARTING TERRAFORM"
export TF_VAR_bucket=$BUCKET_NAME
terraform init -backend-config="bucket=$TF_VAR_bucket"
terraform apply
