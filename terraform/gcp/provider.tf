provider "google" {
  project     = local.config.project.name
  region      = local.region
  credentials = file("${path.module}/keys.json")
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke_cluster.cluster_endpoints["main-cluster"]}"
  cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificates["main-cluster"])
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke_cluster.cluster_endpoints["main-cluster"]}"
    cluster_ca_certificate = base64decode(module.gke_cluster.cluster_ca_certificates["main-cluster"])
    token                  = data.google_client_config.default.access_token
  }
}

terraform {
  backend "gcs" {
    prefix = "terraform/state"
  }
}
