resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

data "template_file" "jenkins_values" {
  template = file("${path.module}/jenkins-values.yaml")

  vars = {
    jenkins_admin_username = var.admin_user
    jenkins_admin_password = var.admin_password
    system_message         = "Welcome to Jenkins kh by ${var.admin_user}"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.1.11" 
  namespace  = kubernetes_namespace.jenkins.metadata[0].name


  values = [
    file("${path.module}/jenkins-values.yaml")
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
