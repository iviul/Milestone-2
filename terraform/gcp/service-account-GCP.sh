#!/bin/bash
set -euo pipefail
#########################################################################
CONFIG_PATH=$1
SERVICE_ACCOUNT_NAME=$(grep -oP '"terraform_username":\s*"\K[^"]+' "$CONFIG_PATH")
PROJECT_ID=$(gcloud config get-value project)
DESCRIPTION="The service account for the Terraform"
KEY_FILE="${2%.json}.json"
BUCKET_NAME=$(grep -oP '"bucket_state_name":\s*"\K[^"]+' $CONFIG_PATH)
NEW_BUCKET_NAME=$BUCKET_NAME-$(date +'%Y-%m-%d-%H-%M-%S')
BUCKET_LOCATION=$(grep -oP '"state_bucket_location_gcp":\s*"\K[^"]+' "$CONFIG_PATH")
DB_USERNAME=postgres # will be taken by grep
DB_PASS=postgres # will be taken by grep
SECRET_NAME_DB_USERNAME=db_username # will be taken by grep
SECRET_NAME_DB_PASS=db_pass # will be taken by grep
#########################################################################
if [[ -z "$PROJECT_ID" ]]; then
	echo "=== Error: Unable to retrieve GCP project ID. Use 'gcloud config set project YOUR_PROJECT_ID' ==="
	exit 1
else
	echo "=== Project's ID: '$PROJECT_ID' ==="
	echo
fi
#########################################################################
REQUIRED_APIS=(
	"iamcredentials.googleapis.com"
	"compute.googleapis.com"
	"cloudresourcemanager.googleapis.com"
	"serviceusage.googleapis.com"
	"storage.googleapis.com"
	"artifactregistry.googleapis.com"
	"secretmanager.googleapis.com"
	"sqladmin.googleapis.com"
)

echo "=== Enabling required APIs for project: $PROJECT_ID ==="
for api in "${REQUIRED_APIS[@]}"; do
	echo "- Enabling '$api'..."
	gcloud services enable "$api" --project="$PROJECT_ID" || echo "=== Failed to enable $api ==="
done
echo "=== All required APIs were enabled ==="
echo
#########################################################################
echo "=== Checking for service account $SERVICE_ACCOUNT_NAME... ==="
if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" > /dev/null 2>&1; 

then
	echo "=== Service account: $SERVICE_ACCOUNT_NAME already exists. ==="
	
	echo
else
	echo "=== Creating service account: $SERVICE_ACCOUNT_NAME ==="
	gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
		--description="$DESCRIPTION" \
		--display-name="$SERVICE_ACCOUNT_NAME"
	echo
fi
#########################################################################
IAM_ROLES=(
	"editor"
	"secretmanager.secretAccessor"
    "iam.serviceAccountViewer"
)
for iam_role in "${IAM_ROLES[@]}"; do
	echo "=== Binding role '$iam_role' to service account... ==="
	gcloud projects add-iam-policy-binding "$PROJECT_ID" \
		--member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
		--role="roles/$iam_role" || echo "=== Role binding may already exist ==="
	echo
done
echo "=== All iam roles were enabled ==="
echo
#########################################################################
echo "=== Checking if key file: $KEY_FILE already exists ==="
if [[ -f "$KEY_FILE" ]]; then
	echo "=== Key file: $KEY_FILE already exists. ==="
	echo
else
	echo "=== Creating key file: $KEY_FILE ==="
	gcloud iam service-accounts keys create "$KEY_FILE" \
		--iam-account="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
	echo
fi
#########################################################################

check_secret_exists() {
    gcloud secrets describe "$1" --project="$2" &>/dev/null
}
# Function to create a secret if it doesn't already exist
create_secret() {
    SECRET_NAME=$1
    PROJECT_ID=$2
    SECRET_VALUE=$3

    if check_secret_exists "$SECRET_NAME" "$PROJECT_ID"; then
        echo "✅ Secret '$SECRET_NAME' already exists."
    else
        echo "Creating secret '$SECRET_NAME'..."
        if gcloud secrets create "$SECRET_NAME" \
                --replication-policy="automatic" \
                --project="$PROJECT_ID"; then
            echo -n "$SECRET_VALUE" | gcloud secrets versions add "$SECRET_NAME" \
                --data-file=- \
                --project="$PROJECT_ID"
            echo "✅ Secret '$SECRET_NAME' created and value added."
        else
            echo "❌ Failed to create secret '$SECRET_NAME'."
            exit 1
        fi
    fi
}
create_secret "$SECRET_NAME_DB_USERNAME" "$PROJECT_ID" "$DB_USERNAME"
create_secret "$SECRET_NAME_DB_PASS" "$PROJECT_ID" "$DB_PASS"
#########################################################################
echo

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"


echo "=== Creating the bucket gs://$NEW_BUCKET_NAME ==="
export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
if gsutil ls "gs://$NEW_BUCKET_NAME"; then
	echo "=== The bucket: gs://$NEW_BUCKET_NAME already exists. ==="
	exit 1
else
	gcloud storage buckets create "gs://$NEW_BUCKET_NAME" \
			--location="$BUCKET_LOCATION" \
			--uniform-bucket-level-access
	echo "=== Enabling versioning on the bucket: gs://$NEW_BUCKET_NAME ==="
	gsutil versioning set on "gs://$NEW_BUCKET_NAME" || echo "=== Versioning already enabled ==="
	echo
fi



#########################################################################
startTerraform() {
	echo "🚀 STARTING TERRAFORM"
	terraform init \
		-backend-config="bucket=$1"
}
startTerraform "$NEW_BUCKET_NAME"
#########################################################################
