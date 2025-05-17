# AWS part

## Terraform Preparation

This toolkit automates the setup of AWS infrastructure for Terraform deployments. It creates a dedicated IAM service user, configures an S3 bucket for Terraform remote state storage, initializes the Terraform backend, and executes the initial deployment.

The toolkit includes the following scripts:

* **`helper.sh`**: The main orchestration script that:
  - Accepts two arguments:
    1. Path to the configuration JSON file containing user and bucket settings
    2. Path to the IAM policy JSON file for the service user
  - Creates a service user with appropriate permissions
  - Sets up an S3 bucket for Terraform remote state
  - Generates an `aws_user_env.sh` file with environment variables
  - Automatically adds `aws_user_env.sh` to `.gitignore`
  - Initializes Terraform backend configuration
  - Runs `terraform apply` to deploy resources

* **`aws-service-iam.sh`**: Creates and configures an AWS IAM user with the specified policy for Terraform operations.

* **`s3-remote.sh`**: Creates and configures an S3 bucket for Terraform remote state storage, including versioning and appropriate access policies.

* **`init.sh`**: Initializes the Terraform working directory with the correct backend configuration for the S3 bucket.

### Prerequisites

* AWS CLI installed and configured and default output set to JSON
* jq must be installed
* Terraform installed
* Appropriate AWS permissions to create IAM users and S3 buckets
* Configuration files:
  - `config.json`: Global config file
  - `policy.json`: Contains the IAM policy for the Terraform service user
  * If you use MacOs 
  ```brew install grep
   ```
   Then use **`ggrep`** instead of **`grep`**


### Usage

1. **Initial Setup**:

   Run the helper script with the configuration and policy files:

   ```powershell
   ./helper.sh ../config.json policy.json
   ```

   This will:
   - Create the service user
   - Set up the S3 bucket
   - Initialize Terraform
   - Run `terraform apply`
   - Generate `aws_user_env.sh` with environment variables

2. **For Subsequent Operations**:

   After system reboot or in new terminal sessions:

   ```powershell
   source aws_user_env.sh
   terraform apply
   ```

   If Terraform is not initialized:

   ```powershell
   source aws_user_env.sh
   ./init.sh
   terraform apply
   ```