resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = var.service_account.account_name
    namespace = var.service_account.namespace
  }
}

resource "kubernetes_cluster_role_binding" "jenkins_admin" {
  metadata {
    name = var.service_account.binding_name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = var.service_account.role_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = var.service_account.namespace
  }
}