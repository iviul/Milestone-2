provider "google" {
  project     = local.config.project.name
  region      = local.region
  credentials = file("${path.module}/keys.json")
}

# data "google_client_config" "default" {}

# provider "kubernetes" {
#   host                   = module.gke_cluster.cluster_endpoints["gke-cluster"]
#   cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificates["gke-cluster"])
#   token                  = data.google_client_config.default.access_token
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.gke_cluster.cluster_endpoints["gke-cluster"]
#     cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificates["gke-cluster"])
#     token                  = data.google_client_config.default.access_token
#   }
# }

terraform {
  backend "gcs" {
    prefix = "terraform/state"
  }
}
