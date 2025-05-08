#!/bin/bash
set -e

CONFIG_FILE=$1
POLICY_DOCUMENT=$2

USER_NAME=$(grep -oP '"terraform_username"\s*:\s*"\K[^"]+' "$CONFIG_FILE")
POLICY_NAME="TerraformAccessPolicy"

if ! aws iam get-user --user-name "$USER_NAME" > /dev/null 2>&1; then
    aws iam create-user --user-name "$USER_NAME" > /dev/null 2>&1 || true
fi

USER_ARN=$(aws iam get-user --user-name "$USER_NAME" --query 'User.Arn' --output text)

POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)
if [ -z "$POLICY_ARN" ]; then
    POLICY_ARN=$(aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file://$POLICY_DOCUMENT --query 'Policy.Arn' --output text)
fi

aws iam attach-user-policy --user-name "$USER_NAME" --policy-arn "$POLICY_ARN"

CREDENTIALS=$(aws iam create-access-key --user-name "$USER_NAME" --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)
ACCESS_KEY_ID=$(echo $CREDENTIALS | awk '{print $1}')
SECRET_ACCESS_KEY=$(echo $CREDENTIALS | awk '{print $2}')

echo "$USER_NAME $ACCESS_KEY_ID $SECRET_ACCESS_KEY $USER_ARN"
