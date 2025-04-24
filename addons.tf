data "aws_eks_addon_version" "cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

resource "aws_eks_addon" "cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"

  addon_version               = data.aws_eks_addon_version.cni.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_access_entry.nodes
  ]
}

// CoreDNS 

# data "aws_eks_addon_version" "coredns" {
#   addon_name         = "coredns"
#   kubernetes_version = aws_eks_cluster.main.version
#   most_recent        = true
# }

# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.main.name
#   addon_name   = "coredns"

#   addon_version               = data.aws_eks_addon_version.coredns.version
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"

#   depends_on = [
#     aws_eks_access_entry.nodes
#   ]
# }

// Kube-Proxy 

data "aws_eks_addon_version" "kubeproxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}

resource "aws_eks_addon" "kubeproxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"

  addon_version               = data.aws_eks_addon_version.kubeproxy.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_access_entry.nodes
  ]
}

// Pod Identity 

data "aws_eks_addon_version" "pod_identity" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}


resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"

  addon_version               = data.aws_eks_addon_version.pod_identity.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_access_entry.nodes
  ]
}

// EFS

data "aws_eks_addon_version" "efs" {
  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
} 

resource "aws_eks_addon" "efs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-efs-csi-driver"

  addon_version               = data.aws_eks_addon_version.efs.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_access_entry.nodes
  ]
}

// EBS

data "aws_eks_addon_version" "ebs" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.main.version
  most_recent        = true
}


resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "aws-ebs-csi-driver"

  addon_version               = data.aws_eks_addon_version.ebs.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_access_entry.nodes
  ]
}