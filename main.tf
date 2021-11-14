data "kustomization_overlay" "resources" {
  resources = [
    "${path.module}/all"
  ]
  kustomize_options = {
    load_restrictor = "none"
  }
  images {
    name     = "docker.io/bitnami/external-dns"
    new_name = "docker.io/willthames/external-dns-with-civo"
    new_tag  = "external-dns-helm-chart-1.5.0-12-g58d26821"
  }
  secret_generator {
    name      = "external-dns-civo-token"
    namespace = "external-dns"
    literals = [
      "CIVO_TOKEN=${var.civo_token}"
    ]
    options {
      disable_name_suffix_hash = true
    }
  }
  patches {
    target = {
      kind = "Deployment"
      name = "external-dns"
    }
    patch = <<-EOF
    - op: add
      path: /spec/template/spec/containers/0/args/-
      value: --domain-filter=${var.domain}
    EOF
  }
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.resources.ids_prio[0]
  manifest = data.kustomization_overlay.resources.manifests[each.value]
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
resource "kustomization_resource" "p1" {
  for_each   = data.kustomization_overlay.resources.ids_prio[1]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each   = data.kustomization_overlay.resources.ids_prio[2]
  manifest   = data.kustomization_overlay.resources.manifests[each.value]
  depends_on = [kustomization_resource.p1]
}
