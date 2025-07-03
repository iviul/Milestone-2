locals {
  config = jsondecode(file("${path.module}/../config-kuber.json"))

  fixed_region_map = {
    aws = "eu-central-1"
    gcp = "europe-west3"
  }

  region      = local.fixed_region_map["gcp"]
  db_password = "password"
  db_username = "user"


  gcp_artifact_registry = one([
    for ar in local.config.artifact_registry : ar
    if ar.provider == "gcp"
  ])

  ssh_keys = local.config.project.keys

  service_account_email = local.config.project.service_account_email


  primary_gke_key = keys(module.gke_cluster.cluster_endpoints)[0]
}

module "network" {
  source            = "./modules/network"
  project_id        = local.config.project.name
  region            = local.region
  networks          = local.config.network
  acls              = local.config.network[0].subnets
  security_groups   = local.config.security_groups
  health_check_port = var.health_check_port
}

module "vm" {
  source                = "./modules/vm"
  project_id            = local.config.project.name
  region                = local.region
  project_os            = local.config.project.os
  vm_instances          = local.config.vm_instances
  subnet_self_links_map = module.network.subnet_self_links_by_name
  ssh_keys              = local.ssh_keys
  depends_on            = [module.network]
  service_account_email = local.service_account_email
}

resource "google_project_service" "monitoring" {
  service                    = "monitoring.googleapis.com"
  project                    = local.config.project.name
  disable_dependent_services = true
}

module "load-balancer" {
  source     = "./modules/load-balancer"
  project_id = local.config.project.name
  region     = local.region
  zone       = "europe-west3-a"
  network    = module.network.vpc_self_links[local.config.load_balancers[0].vpc]
  instances  = module.vm.non_bastion_instances_self_links

  load_balancers = local.config.load_balancers
}

module "db-instance" {
  source            = "./modules/db-instance"
  project_id        = local.config.project.name
  region            = local.region
  databases         = local.config.databases
  private_networks  = module.network.vpc_self_links
  subnet_self_links = module.network.subnet_self_links_by_name
  depends_on        = [module.network]
  db_pass           = local.db_password
  db_username       = local.db_username
}

module "static_ips" {
  source     = "./modules/static_ips"
  static_ips = local.config.static_ips
}

module "cloudflare_dns" {
  source               = "../shared_modules/cloudflare_dns"
  cloudflare_zone_id   = var.cloudflare_zone_id
  dns_records_config   = local.config.dns_records
  resource_dns_map     = module.static_ips.ip_addresses
  cloudflare_api_token = var.cloudflare_api_token
}


module "gke_cluster" {
  source            = "./modules/gke_cluster"
  clusters          = local.config.gke_clusters
  vpc_self_links    = module.network.vpc_self_links
  subnet_self_links = module.network.subnet_self_links_by_name
}

module "monitoring" {
  source = "./modules/monitoring"
  notification_channels = jsondecode(file("${path.module}/../config-kuber.json"))["monitoring"]["notification_channels"]
  log_based_metrics     = jsondecode(file("${path.module}/../config-kuber.json"))["monitoring"]["log_based_metrics"]
  alert_policies        = jsondecode(file("${path.module}/../config-kuber.json"))["monitoring"]["alert_policies"]
}

module "jenkins" {
  source                         = "./modules/jenkins"
  jenkins_admin_username         = local.config.project.jenkins_admin_username
  jenkins_admin_password         = local.config.project.jenkins_admin_password
  jenkins_hostname               = local.config.project.jenkins_hostname
  jenkins_controller_registry    = local.config.project.jenkins_controller_registry
  jenkins_controller_repository  = local.config.project.jenkins_controller_repository
  jenkins_controller_tag         = local.config.project.jenkins_controller_tag
  cluster_endpoint               = module.gke_cluster.cluster_endpoints["main-cluster"]       // change if using more than one cluster
  ca_certificate                 = module.gke_cluster.cluster_ca_certificates["main-cluster"] // change if using more than one cluster
  access_token                   = data.google_client_config.default.access_token
  gcp_credentials_file           = module.jenkins.gcp_credentials_file
  gar_password_base64            = var.gar_password_base64
  cloudflare_api_token           = var.cloudflare_api_token
  JENKINS_GITHUB_SSH_PRIVATE_KEY = var.JENKINS_GITHUB_SSH_PRIVATE_KEY 
  project_id                     = local.config.project.name

  cloud_bucket                   = var.cloud_bucket
  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

module "gke_service_account" {
  source          = "./modules/gke_service_account"
  service_account = local.config.kubernetes_service_account
}

resource "kubernetes_secret" "jenkins_db_secret" {
  metadata {
    name      = "db-secret"
    namespace = "jenkins"
  }

  data = {
    db_host        = module.db-instance.db_hosts[local.db_name]
    db_user        = module.db-instance.db_users[local.db_name]
    db_password    = module.db-instance.db_passwords[local.db_name]
    db_port        = module.db-instance.db_ports[local.db_name]
    db_name        = module.db-instance.db_names[local.db_name]
    gke_ingress_ip = module.static_ips.ip_addresses["gke-ingress-ip"]
  }

  type = "Opaque"

  depends_on = [
    module.db-instance,
    module.static_ips
  ]
}
