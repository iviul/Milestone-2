#!/bin/bash

terraform init \
  -backend-config="bucket=$TF_VAR_s3_bucket" \
  -backend-config="region=$TF_VAR_aws_remote_region" \
  -backend-config="profile=$TF_VAR_aws_user" \
  "$@"