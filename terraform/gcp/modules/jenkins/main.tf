locals {
  gcp_sa_key_b64 = base64encode(file(var.gcp_credentials_file))
}


resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

data "template_file" "jenkins_values" {
  template = file("${path.module}/jenkins-values.yaml.tmpl")

  vars = {
    jenkins_namespace              = "jenkins"
    jenkins_hostname               = var.jenkins_hostname
    jenkins_controller_registry    = var.jenkins_controller_registry
    jenkins_controller_repository  = var.jenkins_controller_repository
    jenkins_controller_tag         = var.jenkins_controller_tag
    jenkins_admin_username         = var.jenkins_admin_username
    jenkins_admin_password         = var.jenkins_admin_password
    gcp_sa_key_b64                 = local.gcp_sa_key_b64
    cloudflare_api_token           = var.cloudflare_api_token
    cloud_bucket                   = var.cloud_bucket
    system_message                 = "Welcome to Jenkins kh by ${var.jenkins_admin_username}!"
    JENKINS_GITHUB_SSH_PRIVATE_KEY = var.JENKINS_GITHUB_SSH_PRIVATE_KEY
    gar_password_base64            = var.gar_password_base64
  }
}

resource "local_file" "jenkins_values_yaml" {
  content  = data.template_file.jenkins_values.rendered
  filename = "${path.module}/jenkins-values.yaml"

}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.1.11"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [
    data.template_file.jenkins_values.rendered
  ]
  depends_on = [kubernetes_namespace.jenkins]
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
  }
}