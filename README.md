# Multi-Cloud Infrastructure Deployment with Terraform and Ansible

This repository contains the infrastructure as code (IaC) for deploying robust and scalable application environments on Google Cloud Platform (GCP) and Amazon Web Services (AWS). It leverages Terraform for provisioning and managing cloud resources, and Ansible for post-deployment configuration and management.



## Project Overview
This project automates the creation of a complete application infrastructure on both GCP and AWS. It defines and provisions:

Virtual Private Cloud (VPC) / Virtual Private Cloud (VPC) Networks and Subnets: Establishing isolated and well-segmented network environments in both clouds.
Virtual Machine (VM) Instances / EC2 Instances: Deploying various compute instances for different application tiers (e.g., reverse proxy, frontend, backend).
Cloud SQL Database Instances / RDS Instances: Provisioning managed database services (PostgreSQL).
Public and Private Access: Strategically placing compute instances in public and private subnets to control network exposure.
Firewall Rules / Security Groups: Implementing granular network security for inter-component communication and external access.
Ansible Roles: Generating dynamic Ansible inventory and roles for managing and configuring the deployed compute instances post-provisioning.
The entire deployment process for each cloud is driven by Terraform configurations, ensuring consistency and repeatability across environments.


## Architecture Highlights
The infrastructure is designed with a tiered architecture, typical for modern web applications, implemented consistently across both cloud providers:

Public Access: Compute instances like reverse proxies and bastion are placed in public subnets, accessible from the internet, handling incoming traffic.
Private Access: Application servers (frontend, backend) and databases reside in private subnets, ensuring they are not directly exposed to the internet, and only accessible from within their respective VPCs (e.g., via the proxy layer).
Managed Database: Utilizes Google Cloud SQL (GCP) or Amazon RDS (AWS) for reliable, scalable, and fully managed database services.
Security: Comprehensive firewall rules (GCP) or Security Groups (AWS) are applied to control traffic flow between tiers and external sources, enhancing security posture.



## Technologies Used

### Google Cloud Platform (GCP):
Compute Engine: For Virtual Machine instances.
Cloud SQL: For managed PostgreSQL databases.
VPC Network: For network infrastructure.


### Amazon Web Services (AWS):
EC2: For Virtual Machine instances.
RDS: For managed PostgreSQL databases.
VPC: For network infrastructure.


Terraform: For declarative infrastructure provisioning and management (Infrastructure as Code).
Ansible: For configuration management and automation on the deployed VMs.
Bash Scripting: To orchestrate the deployment process 
JSON: For defining infrastructure configurations (config.json) in a Private repository.


## Prerequisites
Before you begin, ensure you have the following installed and configured on your local machine:

Google Cloud CLI (gcloud CLI): For interacting with GCP services and authentication.

AWS CLI: For interacting with AWS services and authentication.

Terraform: For infrastructure provisioning.

Ansible: For post-deployment configuration.


A GCP Project: With appropriate APIs enabled (Compute Engine API, Cloud SQL Admin API, Service Usage API, IAM API).
An AWS Account: With configured IAM user and permissions for creating resources.
SSH Key Pair: A public SSH key is required for accessing the deployed VM instances in both clouds.
