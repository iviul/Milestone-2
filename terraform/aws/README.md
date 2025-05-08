# AWS part

## Overview

The toolkit includes the following scripts:

* **`helper.sh`**: The main script that orchestrates the creation of a service account and an S3 bucket for Terraform remote state. It accepts two arguments:

  1. Path to the shared AWS credentials file.
  2. Path to the IAM policy file for the new user.

  After execution, it:

  * Adds the new user's credentials to `~/.aws/credentials`.
  * Generates an `aws_user_env.sh` file to set environment variables for the new user.
  * Automatically appends `aws_user_env.sh` to `.gitignore`.

* **`create_service_user.sh`**: Creates a new AWS IAM user with the specified policy.

* **`create_remote_state_bucket.sh`**: Creates an S3 bucket configured for Terraform remote state storage.

* **`init.sh`**: Initializes the Terraform working directory with the appropriate backend configuration using `terraform init`.

## Prerequisites

* AWS CLI installed and configured.
* Terraform installed.
* Appropriate AWS permissions to create IAM users and S3 buckets.

## Usage

1. Ensure you have your shared AWS credentials file and IAM policy file ready.

2. Run the helper script:

   ```bash
   ./helper.sh /path/to/shared_credentials /path/to/iam_policy.json
   ```



3. Source the generated environment variables:

   ```bash
   source aws_user_env.sh
   ```



4. Initialize Terraform with the backend configuration:

   ```bash
   ./init.sh
   ```
