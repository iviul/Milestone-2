# VM Module

This module creates virtual machine instances on Google Cloud Platform (GCP).

## Inputs
- `project_id`: The ID of the GCP project.
- `region`: The region where the VM instances will be created.
- `project_os`: The operating system for the VM instances.
- `vm_instances`: Configuration for the VM instances.
- `subnet_self_links_map`: Subnet self-links map for the VM instances.

## Outputs
- `instance_ids`: The IDs of the created VM instances. 