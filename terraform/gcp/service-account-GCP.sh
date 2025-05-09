#!/bin/bash
set -euo pipefail
#######################################################
JSON_CONFIG_FILE=../../config/config.json
SERVICE_ACCOUNT_NAME=$(grep -oP '"terraform_username":\s*"\K[^"]+' $JSON_CONFIG_FILE)
ROLE=roles/$1
PROJECT_ID=$(gcloud config get-value project)
DESCRIPTION="The service account for the Terraform"
KEY_FILE=$2
BUCKET_NAME=$(grep -oP '"bucket_state_name":\s*"\K[^"]+' $JSON_CONFIG_FILE)
BUCKET_LOCATION=$(grep -oP '"state_bucket_location_gcp":\s*"\K[^"]+' $JSON_CONFIG_FILE)
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
executeCommands() {
	local command=$1
	local result_true=$2
	local result_false=$3

	if eval $command; then
		echo "=== $result_true ==="
		echo
	else
		echo "=== $result_false ==="
		exit 1
	fi
}
#######################################################
echo "=== Creating service account $SERVICE_ACCOUNT_NAME... ==="
executeCommands \
	"gcloud iam service-accounts create \"$SERVICE_ACCOUNT_NAME\" \
		--description=\"$DESCRIPTION\" \
		--display-name=\"$SERVICE_ACCOUNT_NAME\"" \
	"The service account $SERVICE_ACCOUNT_NAME created successfully!" \
	"Error: The service account '$SERVICE_ACCOUNT_NAME' already exists, try another name. Skipping creation..."
#######################################################
echo "=== Binding role '$ROLE' to the service account... ==="
executeCommands \
	"gcloud projects add-iam-policy-binding \"$PROJECT_ID\" \
		--member=\"serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com\" \
		--role=\"$ROLE\"" \
	"The role '$ROLE' was bound to the service account!" \
	"Error: Failed to bind role '$ROLE' to the service account."
#######################################################
echo "=== Generating key file for $SERVICE_ACCOUNT_NAME... ==="
executeCommands \
	"gcloud iam service-accounts keys create \"$KEY_FILE\" \
		--iam-account=\"$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com\"" \
	"Key file created: $KEY_FILE" \
	"Error: Failed to create key file for service account $SERVICE_ACCOUNT_NAME."
#######################################################
echo "=== Activating service account using the key... ==="
executeCommands \
	"gcloud auth activate-service-account \
		--key-file=$KEY_FILE" \
	"Service account activated successfully!" \
	"Error: Failed to activate the service account."
#######################################################
echo "=== The service account - '$SERVICE_ACCOUNT_NAME' successfully configured via GCP CLI profile! ==="
echo
#######################################################
echo "=== Creating the bucket 'gs://$BUCKET_NAME'...  ==="
executeCommands \
	"gcloud storage buckets create gs://$BUCKET_NAME \
		--location=$BUCKET_LOCATION \
		--uniform-bucket-level-access" \
	"The bucket 'gs://$BUCKET_NAME' was created successfully!" \
	"Error: a bucket 'gs://$BUCKET_NAME' wasn't created. The bucket name '$BUCKET_NAME' already exists, try another name. Skipping creation..."
#######################################################
echo "=== Enabling versioning for 'gs://$BUCKET_NAME'... ==="
executeCommands \
	"gsutil versioning set on gs://$BUCKET_NAME" \
	"Enabled versioning for 'gs://$BUCKET_NAME'!" \
	"Wasn't enabled versioning for 'gs://$BUCKET_NAME'"
#######################################################
