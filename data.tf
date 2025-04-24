data "aws_ssm_parameter" "vpc" {
  name = var.ssm_vpc
}

data "aws_caller_identity" "current" {
  
}

data "aws_ssm_parameter" "subnets" {
  count = length(var.ssm_subnets)
  name  = var.ssm_subnets[count.index]
}

data "aws_ssm_parameter" "lb_subnets" {
  count = length(var.ssm_lb_subnets)
  name  = var.ssm_lb_subnets[count.index]
}


data "aws_ssm_parameter" "lb_grafana_subnets" {
  count = length(var.ssm_grafana_subnets)
  name  = var.ssm_grafana_subnets[count.index]
}


data "aws_eks_cluster_auth" "default" {
  name = aws_eks_cluster.main.id
}

data "aws_ssm_parameter" "karpenter_ami" {
  count = length(var.karpenter_capacity)
  name  = var.karpenter_capacity[count.index].ami_ssm
}
