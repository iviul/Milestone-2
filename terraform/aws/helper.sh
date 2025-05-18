#!/bin/bash
set -e

CONFIG_FILE=$1
POLICY_DOCUMENT=$2

read -p 'First off, specify a full path to your private key: ' KEY_PATH
if [ ! -f "$KEY_PATH" ]; then
    echo "Key file not found: $KEY_PATH"
    exit 1
fi

echo "=== Creating user and policy ==="
USER_OUTPUT=$(./aws-service-iam.sh "$CONFIG_FILE" "$POLICY_DOCUMENT")
USER_NAME=$(echo $USER_OUTPUT | awk '{print $1}')
USER_ARN=$(echo $USER_OUTPUT | awk '{print $2}')
echo "User $USER_NAME was created with ARN $USER_ARN"

echo "=== Creating bucket and bucket policy ==="
BUCKET_OUTPUT=$(./s3-remote.sh "$CONFIG_FILE" "$USER_ARN")
BUCKET_NAME=$(echo $BUCKET_OUTPUT | awk '{print $1}')
REGION=$(echo $BUCKET_OUTPUT | awk '{print $2}')
echo "Bucket $BUCKET_NAME was created in region $REGION"

ENV_FILE="aws_user_env.sh"
echo "Creating environment file: $ENV_FILE"
cat > "$ENV_FILE" <<EOL
export TF_VAR_aws_user=$USER_NAME
export TF_VAR_s3_bucket=$BUCKET_NAME
export TF_VAR_aws_remote_region=$REGION
export TF_VAR_private_key_path="$KEY_PATH"
EOL
chmod +x "$ENV_FILE"

GITIGNORE_FILE=".gitignore"
if [ ! -f "$GITIGNORE_FILE" ]; then
    touch "$GITIGNORE_FILE"
fi
if ! grep -Fxq "$ENV_FILE" "$GITIGNORE_FILE"; then
    echo "$ENV_FILE" >> "$GITIGNORE_FILE"
    echo "Added $ENV_FILE to $GITIGNORE_FILE"
fi

echo "✅ Done. You can now run: source $ENV_FILE"
echo "=== Initialize Terraform backend ==="
source "$ENV_FILE"

echo "Using user: $TF_VAR_aws_user"
echo "Bucket: $TF_VAR_s3_bucket"
echo "Region: $TF_VAR_aws_remote_region"

./init.sh

echo "=== Run Terraform apply ==="
terraform apply