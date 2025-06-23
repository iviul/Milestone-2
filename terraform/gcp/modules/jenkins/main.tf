resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

data "template_file" "jenkins_values" {
  template = file("${path.module}/jenkins-values.yaml.tmpl")

  vars = {
    jenkins_namespace = "jenkins"
    jenkins_hostname       = var.jenkins_hostname
    ingress_class          = var.ingress_class
    jenkins_admin_username = var.jenkins_admin_username
    jenkins_admin_password = var.jenkins_admin_password
    jenkins_tls_secret_name = var.jenkins_tls_secret_name
    system_message         = "Welcome to Jenkins kh by ${var.jenkins_admin_username}!"
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
