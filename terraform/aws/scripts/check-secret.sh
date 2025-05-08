#!/bin/bash
set -euo pipefail

# Validate input
if [[ -z "${1:-}" ]]; then
  jq -n --arg error "Missing identifier argument" '{error: $error}' >&2
  exit 1
fi

identifier="$1"
secret_name="db-credentials-${identifier}"

# Check secret existence
aws_response=$(aws secretsmanager describe-secret --secret-id "$secret_name" 2>&1 || true)

if [[ "$aws_response" == *"ResourceNotFoundException"* ]]; then
  jq -n '{exists: "false", "name":"'"$secret_name"'"}'
elif [[ "$aws_response" == *"ARN"* ]]; then
  jq -n '{exists: "true", "name":"'"$secret_name"'"}'
else
  jq -n --arg error "$aws_response" '{error: $error}' >&2
  exit 1
fi