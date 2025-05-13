# Milestone-2

# Milestone-2 Infrastructure Deployment

This project provisions a secure and scalable cloud infrastructure in **Google Cloud Platform (GCP)** **AWS** using **Terraform**. It is designed to host a future application deployment in a private network, with access managed through a bastion host and SSH agent forwarding.

---

## Purpose

The goal of this infrastructure is to provide a stable foundation for deploying a cloud-native application. It includes:

- Isolated private subnet for internal virtual machines
- A bastion host for secure SSH access
- A managed PostgreSQL database
- Networking components with NAT gateway and firewall rules
- Role-based access control via IAM

---

## Infrastructure Components

| Component          | Description |
|--------------------|-------------|
| **VPC**            | Custom VPC with public and private subnets |
| **NAT Gateway**    | Allows internal instances to reach the internet securely |
| **Bastion Host**   | Public VM used to access internal private instances via SSH |
| **4 Private VMs**  | Application nodes in private subnet |
| **PostgreSQL DB**  | Managed database instance (Cloud SQL) |
| **IAM Roles**      | Scoped roles for instances and service accounts |
| **Service Accounts** | Used for VM access and cloud resource permissions |

---

## Prerequisites

Before launching the infrastructure, ensure you have the following installed locally:

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- SSH key pair (`.pem` format) with:
  - **Private key** stored locally
  - **Public key** defined in Terraform files
- Properly configured GCP project and credentials

---

## Deployment

To deploy the infrastructure:

```bash
# Clone the repository
git clone https://github.com/your-org/milestone-2-infra.git
cd milestone-2-infra

# Authenticate with Google Cloud
gcloud auth application-default login
gcloud config set project [YOUR_PROJECT_ID]

# Initialize Terraform
terraform init

# Preview changes
terraform plan -var-file="terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="terraform.tfvars"

## The deployment will:

Create networking (VPC, subnets, NAT)

Launch bastion and internal VMs

Provision a Cloud SQL PostgreSQL instance

Configure IAM roles and service accounts


## Accessing Instances via Bastion
SSH access is only allowed through the bastion host using SSH Agent Forwarding.

1. Start your SSH agent locally:

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/internal-key.pem
2. Connect to the bastion host:

ssh -A -i ~/.ssh/bastion-key.pem username@<bastion-public-ip>
3. From the bastion, SSH into a private VM:

ssh username@<private-vm-ip>
Note: The private key for internal VMs is never copied to the bastion.

## Connecting to PostgreSQL
Once deployed, you can connect to the PostgreSQL database in two ways:

# Option 1: Through Cloud SQL Proxy (recommended)
Install the Cloud SQL Proxy and run:

./cloud-sql-proxy --credentials-file=your-service-account.json \
  --instances="your-project:region:instance-id"=tcp:5432
Then connect with:

psql -h 127.0.0.1 -U postgres -d your_db_name


# Option 2: Directly from bastion 

psql -h <cloud-sql-private-ip> -U postgres -d your_db_name



## Security
Private VMs are not accessible from the internet.

SSH access is tightly controlled via bastion and SSH agent forwarding.

Secrets (e.g., database credentials, service account keys) are stored securely and passed via Terraform variables.
