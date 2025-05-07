#!/bin/bash
set -euo pipefail
#######################################################
SERVICE_ACCOUNT_NAME=$1
ROLE=$2
PROJECT_ID=$(gcloud config get-value project)
DESCRIPTION="The service account for the Terraform"
KEY_FILE=$3
#######################################################
if [[ -z "$PROJECT_ID" ]]; then
    echo "- Error: Unable to retrieve GCP project ID. Ensure your GCP project is set."
    exit 1
fi
#######################################################
echo "- Enabling IAM Service Account Credentials API..."

gcloud services enable iamcredentials.googleapis.com --project=$PROJECT_ID

echo "- IAM Service Account Credentials API enabled"
#######################################################
echo "- Checking if service account '$SERVICE_ACCOUNT_NAME' already exists..."
if gcloud iam service-accounts list \
        --filter="email:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
        --format="value(email)" | grep -q "$SERVICE_ACCOUNT_NAME"; then
	echo "- Service account '$SERVICE_ACCOUNT_NAME' already exists. Skipping creation..."
else
	echo "- Creating service account $SERVICE_ACCOUNT_NAME..."
	gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
		--description="$DESCRIPTION" \
        --display-name="$SERVICE_ACCOUNT_NAME"
fi
#######################################################
echo "- Binding role '$ROLE' to the service account..."
if ! gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
        --role="$ROLE"; then
    echo "- Error: Failed to bind role '$ROLE' to the service account."
    exit 1
fi
#######################################################
echo "- Generating key file for $SERVICE_ACCOUNT_NAME..."
if gcloud iam service-accounts keys create "$KEY_FILE" \
        --iam-account="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"; then
    echo "- Key file created: $KEY_FILE"
else
    echo "- Error: Failed to create key file for service account $SERVICE_ACCOUNT_NAME."
    exit 1
fi
#######################################################
echo "- Activating service account using the key..."
# if gcloud auth activate-service-account "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
#       --key-file="$KEY_FILE" --project="$PROJECT_ID"; then
#     echo "- Service account activated successfully."
if gcloud auth activate-service-account \
        --key-file=$KEY_FILE; then
    echo "- Service account activated successfully."
else
    echo "- Error: Failed to activate the service account."
    exit 1
fi
#######################################################
echo "- The service account - '$SERVICE_ACCOUNT_NAME' successfully configured via GCP CLI profile."
#######################################################
