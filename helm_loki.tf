resource "helm_release" "loki" {
  name       = "loki"
  chart      = "loki"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = "loki"

  create_namespace = true

  values = [
    local.loki["values"]
  ]


  depends_on = [
    helm_release.karpenter,
    aws_eks_pod_identity_association.loki,
    aws_eks_addon.ebs_csi
  ]
}