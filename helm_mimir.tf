resource "helm_release" "mimir" {
  name       = "mimir"
  chart      = "mimir-distributed"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = "mimir"

  create_namespace = true

  values = [
    local.mimir["values"]
  ]

  timeout  = 900

  depends_on = [
    helm_release.karpenter,
    aws_eks_pod_identity_association.mimir,
    aws_eks_addon.ebs_csi
  ]
}