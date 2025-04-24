resource "aws_eks_node_group" "main" {

  cluster_name    = aws_eks_cluster.main.id
  node_group_name = aws_eks_cluster.main.id

  node_role_arn = aws_iam_role.eks_nodes_role.arn

  instance_types = [ "t3a.large" ]

  subnet_ids = data.aws_ssm_parameter.subnets[*].value

  scaling_config {
    desired_size = var.node_group_temp_desired
    max_size     = var.node_group_temp_desired
    min_size     = var.node_group_temp_desired
  }

  capacity_type = "SPOT"

  labels = {
    "capacity/os"   = "BOTTLEROCKET"
    "capacity/arch" = "x86_64"
    "capacity/type" = "SPOT"
    "compute-type"  = "ec2"
  }

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }

  depends_on = [
    aws_eks_access_entry.nodes
  ]

  timeouts {
    create = "1h"
    update = "2h"
    delete = "2h"
  }

}