variable "project_name" {
  description = "Nome curto do projeto ou workload; é usado como prefixo na criação dos recursos e facilita a identificação em toda a conta AWS."
}

variable "region" {
  description = "Região AWS onde os recursos serão provisionados. O valor padrão está definido para us‑east‑1, mas pode ser alterado se necessário."
  default     = "us-east-1"
}

variable "k8s_version" {
  description = "Versão desejada do Kubernetes no EKS. Mantenha alinhada à versão suportada pela AWS para evitar incompatibilidades."
  default     = "1.32"
}

variable "ssm_vpc" {
  description = "Path do parâmetro no AWS SSM Parameter Store que contém o ID da VPC utilizada pelo cluster."
}

variable "ssm_subnets" {
  description = "Lista de paths no SSM que apontam para os IDs das sub‑redes privadas onde os nós do cluster serão criados."
  type        = list(string)
}

variable "ssm_lb_subnets" {
  description = "Lista de paths no SSM que referenciam as sub‑redes públicas destinadas aos load balancers (ALB/NLB) do ambiente."
  type        = list(string)
}

variable "ssm_grafana_subnets" {
  description = "Lista de paths no SSM para as sub‑redes onde o Grafana será implantado, garantindo isolamento adequado da solução de observabilidade."
  type        = list(string)
}

variable "node_group_temp_desired" {
  description = "Quantidade inicial de nós a serem criados no Node Group temporário de bootstrap. Ideal para acelerar o provisionamento até que o Karpenter assuma o escalonamento."
  type        = number
  default     = 2
}


variable "karpenter_capacity" {
  description = "Configuração dos NodePools e EC2NodeClasses do Karpenter. Cada item da lista representa um NodePool, com suas respectivas configurações."
  type = list(object({
    name               = string
    workload           = string
    ami_family         = string
    ami_ssm            = string
    instance_family    = list(string)
    instance_sizes     = list(string)
    capacity_type      = list(string)
    availability_zones = list(string)
  }))
}

variable "clusters_configs" {
  description = "Customização dos Secrets do ArgoCD para autenticação entre os clusters que vão ser gerenciados. Permite declarar múltiplos clusters, cada um identificado por cluster_name."
  default = [
    {
      cluster_name = "linuxtips-cluster-01"
    },
    {
      cluster_name = "linuxtips-cluster-02"
    }
  ]
}
