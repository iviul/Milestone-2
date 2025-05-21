# Database Instance Module

This module creates a database instance on Google Cloud Platform (GCP).

## Inputs
- `project_id`: The ID of the GCP project.
- `region`: The region where the database instance will be created.
- `databases`: Configuration for the databases to be created.
- `private_networks`: Private networks for the database instance.
- `subnet_self_links`: Subnet self-links for the database instance.

## Outputs
- `instance_connection_name`: The connection name of the created database instance. 