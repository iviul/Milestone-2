#!/bin/bash
set -euo pipefail
#######################################################
SERVICE_ACCOUNT_NAME=$1
ROLE=$2
PROJECT_ID=$(gcloud config get-value project)
DESCRIPTION="The service account for the Terraform"
KEY_FILE=$3
BUCKET_NAME=$4
#######################################################
if [[ -z "$PROJECT_ID" ]]; then
    echo "- Error: Unable to retrieve GCP project ID. Ensure your GCP project is set."
    exit 1
else
    echo "=== Project's id: '$PROJECT_ID' ==="
    echo
fi
#######################################################
REQUIRED_APIS=(
    "iamcredentials.googleapis.com"
    "compute.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "serviceusage.googleapis.com"
    "storage.googleapis.com"
)
echo "=== Enabling required APIs for project: $PROJECT_ID ==="
for api in "${REQUIRED_APIS[@]}"; do
    echo "- Enabling '$api'..."
    if gcloud services enable "$api" \
        --project=$PROJECT_ID; then
        echo "- '$api' was enabled"
    else
        echo "- '$api' wasn't enabled"
        exit 1
    fi
done
echo "=== Required APIs for project $PROJECT_ID were enabled! ==="
echo
#######################################################
echo "=== Checking if service account '$SERVICE_ACCOUNT_NAME' already exists... ==="
if gcloud iam service-accounts list \
    --filter="email:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --format="value(email)" | grep -q "$SERVICE_ACCOUNT_NAME"; then
	echo "=== Service account '$SERVICE_ACCOUNT_NAME' already exists. Skipping creation... ==="
    echo
else
	echo "=== Creating service account $SERVICE_ACCOUNT_NAME... ==="
	gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
    --description="$DESCRIPTION" \
    --display-name="$SERVICE_ACCOUNT_NAME"
    echo
fi
#######################################################
echo "=== Binding role '$ROLE' to the service account... ==="
if gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="$ROLE"; then
    echo "=== The role '$ROLE' was bound to the service account! ==="
    echo
else
    echo "=== Error: Failed to bind role '$ROLE' to the service account. ==="
    exit 1
fi
#######################################################
echo "=== Generating key file for $SERVICE_ACCOUNT_NAME... ==="
if gcloud iam service-accounts keys create "$KEY_FILE" \
    --iam-account="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"; then
    echo "=== Key file created: $KEY_FILE ==="
    echo
else
    echo "=== Error: Failed to create key file for service account $SERVICE_ACCOUNT_NAME. ==="
    exit 1
fi
#######################################################
echo "=== Activating service account using the key... ==="
if gcloud auth activate-service-account \
    --key-file=$KEY_FILE; then
    echo "=== Service account activated successfully! ==="
    echo
else
    echo "=== Error: Failed to activate the service account. ==="
    exit 1
fi
#######################################################
echo "=== The service account - '$SERVICE_ACCOUNT_NAME' successfully configured via GCP CLI profile! ==="
echo
#######################################################
echo "=== Creating the bucket 'gs://$BUCKET_NAME'...  ==="
if gcloud storage buckets create gs://$BUCKET_NAME \
    --location=us-central1 \
    --uniform-bucket-level-access; then
    echo "=== The bucket 'gs://$BUCKET_NAME' was created successfully! ==="
    echo
else
    echo "=== Error: a bucket 'gs://$BUCKET_NAME' wasn't created. The bucket name '$BUCKET_NAME' already exists, try another name ==="
    exit 1
fi
#######################################################
echo "=== Enabling versioning for 'gs://$BUCKET_NAME'... ==="
if gsutil versioning set on gs://$BUCKET_NAME; then
    echo "=== Enabled versioning for 'gs://$BUCKET_NAME'! ==="
    echo
else
    echo "=== Wasn't enabled versioning for 'gs://$BUCKET_NAME' ==="
    exit 1
fi
#######################################################
