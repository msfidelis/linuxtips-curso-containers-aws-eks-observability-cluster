resource "helm_release" "alb_ingress_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = true

  set {
    name  = "clusterName"
    value = var.project_name
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.region
  }


  set {
    name  = "vpcId"
    value = data.aws_ssm_parameter.vpc.value

  }

  depends_on = [
    aws_eks_cluster.main,
  ]
}