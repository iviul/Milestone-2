#!/bin/bash
set -e
#######################################################
SERVICE_ACCOUNT_NAME=$1
ROLE=$2
PROJECT_ID=$(gcloud config get-value project)
DESCRIPTION="The service account for the Terraform"
KEY_FILE="$SERVICE_ACCOUNT_NAME-key.json"
#######################################################
echo "- Checking if service account '$SERVICE_ACCOUNT_NAME' already exists..."

if gcloud iam service-accounts list --filter="email:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" --format="value(email)" | \
	grep -q "$SERVICE_ACCOUNT_NAME"; then
	echo "- Service account '$SERVICE_ACCOUNT_NAME' already exists. Skipping creation..."

else
	echo "- Creating service account $SERVICE_ACCOUNT_NAME..."
	gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
		--description="$DESCRIPTION" \
        --display-name="$SERVICE_ACCOUNT_NAME"
fi
#######################################################
echo "- Binding role $ROLE to the service account..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="$ROLE"
#######################################################
echo "- Generating key file for '$SERVICE_ACCOUNT_NAME'..."
gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
#######################################################
echo "- Activating service account using the key..."
gcloud auth activate-service-account "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --key-file="$KEY_FILE" --project="$PROJECT_ID"
#######################################################
echo "- The service account - '$SERVICE_ACCOUNT_NAME' successfully configured via GCP CLI profile."
