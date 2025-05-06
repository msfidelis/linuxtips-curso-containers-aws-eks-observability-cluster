# Cluster de Observabilidade - Projeto Final do "Descomplicando o EKS" - :rocket: :rocket: :rocket: - Grafana Stack as Service

Repositório do [projeto final do módulo de EKS](https://github.com/msfidelis/linuxtips-curso-containers-aws/tree/main/extras/eks-projeto-final) dos cursos "Arquitetura de Containers na AWS" e o "Descomplicando o EKS". 

### Componentes Principais

* **Grafana Loki**: Indexação de Logs
* **Grafana Tempo**: Indexação de Traces e Spans
* **Grafana Mimir**: Indexação de Métricas do prometheus 
* **Grafana Dashboard**: Visualização de Dados, Métricas, Logs e Traces
* **FluentBit**: Captura e envio de logs do Kubernetes para o Loki
* **OpenTelemetry Collector**: Envio de Traces e Spans para o Tempo
* **Prometheus**: Coleta de Métricas e envio para o Mimir


# Outros Repositórios do Projeto 

| Repositório                       | Link                                                                                                                  |
|-----------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| VPC / Networking                  | [Github](https://github.com/msfidelis/linuxtips-curso-containers-aws-eks-networking)                                  |
| Ingress Application Load Balancer | [Github](https://github.com/msfidelis/linuxtips-curso-containers-aws-eks-multicluster-management/tree/main/ingress)   |
| EKS Cluster 01 e 02               | [Github](https://github.com/msfidelis/linuxtips-curso-containers-aws-eks-multicluster-management/tree/main/clusters)  |
| EKS Control Plane do ArgoCD       | [Github](https://github.com/msfidelis/linuxtips-curso-containers-aws-eks-multicluster-management/tree/main/clusters)  |
| EKS Observability Cluster Tools   | [Github](https://github.com/msfidelis/linuxtips-curso-containers-aws-eks-observability-cluster)                       |



# Arquitetura de Ingestão de Métricas, Logs e Traces

![Stack](.github/assets/observability-stack.drawio.png)


# Arquitetura do Grafana

![Stack Grafana](.github/assets/observability-stack-grafana.drawio.png)