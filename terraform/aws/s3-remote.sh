#!/bin/bash
set -e

CONFIG_FILE=$1
USER_ARN=$2

BUCKET_NAME=$(grep -oP '"bucket_state_name"\s*:\s*"\K[^"]+' "$CONFIG_FILE")
REGION=$(grep -oP '"state_bucket_location_aws"\s*:\s*"\K[^"]+' "$CONFIG_FILE")

if ! aws s3api head-bucket --bucket "$BUCKET_NAME" > /dev/null 2>&1; then
    
    aws s3api create-bucket --bucket "$BUCKET_NAME" \
      --region "$REGION" \
      --create-bucket-configuration LocationConstraint="$REGION" # > /dev/null 2>&1
fi

cat > bucket-policy.json <<EOL
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "$USER_ARN"
            },
            "Action": [
            "s3:ListBucket",
            "s3:PutObject",
            "s3:GetObject"],
            "Resource": [
                "arn:aws:s3:::$BUCKET_NAME",
                "arn:aws:s3:::$BUCKET_NAME/*"
            ]
        }
    ]
}
EOL

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://bucket-policy.json #> /dev/null 2>&1

aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled > /dev/null 2>&1
			
rm bucket-policy.json
echo "$BUCKET_NAME $REGION"
