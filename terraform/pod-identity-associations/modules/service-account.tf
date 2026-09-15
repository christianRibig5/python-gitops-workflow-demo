
resource "kubernetes_service_account" "app_sa" {
  for_each = var.create_service_account ? var.pod_identities : {}

  metadata {
    name      = each.value.service_account_name
    namespace = each.value.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = each.key
    }
  }

  depends_on = [
    kubernetes_namespace.namespace
  ]
}
