resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.3.3"

  set {
    name  = "settings.clusterName"
    value = var.project_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = aws_eks_cluster.main.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.nodes.name
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1000m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
  ]

}