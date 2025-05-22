# Network Module

This module sets up a network on Google Cloud Platform (GCP).

## Inputs
- `project_id`: The ID of the GCP project.
- `region`: The region where the network will be set up.
- `networks`: Configuration for the networks.
- `acls`: Access control lists for the network.
- `security_groups`: Security groups for the network.

## Outputs
- `vpc_self_links`: The self-links of the created VPCs. 