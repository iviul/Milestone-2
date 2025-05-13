#!/bin/bash
set -euo pipefail
#########################################################################
CONFIG_PATH=$1
SERVICE_ACCOUNT_NAME=$(grep -oP '"terraform_username":\s*"\K[^"]+' "$CONFIG_PATH")
ROLE="roles/$2"
PROJECT_ID=$(gcloud config get-value project)
DESCRIPTION="The service account for the Terraform"
KEY_FILE=$3
BUCKET_NAME=$(grep -oP '"bucket_state_name":\s*"\K[^"]+' $CONFIG_PATH)
NEW_BUCKET_NAME=$BUCKET_NAME-$(date +'%Y-%m-%d-%H-%M-%S')
BUCKET_LOCATION=$(grep -oP '"state_bucket_location_gcp":\s*"\K[^"]+' "$CONFIG_PATH")
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
)

echo "=== Enabling required APIs for project: $PROJECT_ID ==="
for api in "${REQUIRED_APIS[@]}"; do
	echo "- Enabling '$api'..."
	gcloud services enable "$api" --project="$PROJECT_ID" || echo "=== Failed to enable $api ==="
done
echo "=== All required APIs attempted to enable. ==="
echo
#########################################################################
echo "=== Checking for service account $SERVICE_ACCOUNT_NAME... ==="
if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" &>/dev/null; then
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
echo "=== Binding role '$ROLE' to service account... ==="
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
	--member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
	--role="$ROLE" || echo "=== Role binding may already exist ==="
echo
###
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
	--member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
	--role="roles/secretmanager.secretAccessor"
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
echo "=== Activating service account... ==="
gcloud auth activate-service-account \
	"$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
		--key-file="$KEY_FILE" || {
    echo "=== Failed to activate service account. Check time sync or key validity. ==="
    exit 1
}
#########################################################################
DB_USERNAME=postgres
DB_PASS=postgres
SECRET_NAME_DB_USERNAME=db_user
SECRET_NAME_DB_PASS=db_pass

createSecret() {
	SECRET_NAME=$1
    PROJECT_ID=$2
    SECRET_VALUE=$3
	echo
	echo "=== Creating secret ==="

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

createSecret "$SECRET_NAME_DB_USERNAME" "$PROJECT_ID" "$DB_PASS"
#########################################################################
echo
export GOOGLE_APPLICATION_CREDENTIALS=$KEY_FILE
startTerraform() {
	echo "🚀 STARTING TERRAFORM"
	terraform init --reconfigure \
		-backend-config="bucket=$1"
}

echo "=== Creating the bucket gs://$NEW_BUCKET_NAME ==="
if gsutil ls "gs://$NEW_BUCKET_NAME"; then
	echo "=== The bucket: gs://$NEW_BUCKET_NAME already exists. Creating a new bucket... ==="
	while true; do
		# Generate a unique bucket name with a timestamp
		UPDATED_BUCKET_NAME="${BUCKET_NAME}-$(date +'%Y-%m-%d-%H-%M-%S')"

		if gcloud storage buckets create "gs://$UPDATED_BUCKET_NAME" \
                --location="$BUCKET_LOCATION" \
                --uniform-bucket-level-access; then
			echo "=== The bucket: gs://$UPDATED_BUCKET_NAME created seccessfully ==="
			echo

			echo "=== Enabling versioning on the bucket: gs://$UPDATED_BUCKET_NAME ==="
			gsutil versioning set on "gs://$UPDATED_BUCKET_NAME" || echo "=== Versioning already enabled ==="
			echo

			startTerraform "$UPDATED_BUCKET_NAME"

			break
		else
			echo "=== The bucket: gs://$UPDATED_BUCKET_NAME already exists( Trying again... ==="
		fi
	done
else
	gcloud storage buckets create "gs://$NEW_BUCKET_NAME" \
            --location="$BUCKET_LOCATION" \
            --uniform-bucket-level-access
	echo "=== Enabling versioning on the bucket: gs://$NEW_BUCKET_NAME ==="
	gsutil versioning set on "gs://$NEW_BUCKET_NAME" || echo "=== Versioning already enabled ==="
	echo
fi
#########################################################################
startTerraform "$NEW_BUCKET_NAME"
#########################################################################
