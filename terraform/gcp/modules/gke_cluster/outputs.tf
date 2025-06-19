output "cluster_endpoints" {
  description = "Endpoints of the GKE clusters"
  value       = { for k, v in google_container_cluster.gke : k => v.endpoint }
  sensitive   = false
}

output "cluster_ca_certificates" {
  description = "CA certificates of the GKE clusters"
  value       = { for k, v in google_container_cluster.gke : k => v.master_auth.0.cluster_ca_certificate }
  sensitive   = false
}