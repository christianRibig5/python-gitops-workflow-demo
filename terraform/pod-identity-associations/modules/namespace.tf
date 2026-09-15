resource "kubernetes_namespace" "namespace" {
  for_each = var.create_namespace ? toset(distinct([
    for identity in values(var.pod_identities) :
    identity.namespace
    if identity.namespace != "kube-system"
  ])) : toset([])

  metadata {
    name = each.value
  }
}
