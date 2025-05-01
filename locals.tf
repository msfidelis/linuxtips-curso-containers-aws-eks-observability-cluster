locals {
  grafana = {
    values: <<-VALUES
adminUser: admin
adminPassword: linuxtips        
        
persistence:
    enabled: true
    size: 10Gi
    storageClassName: efs-grafana
service:
    type: NodePort
initChownData:
    enabled: false

nodeSelector:
    karpenter.sh/nodepool: grafana


datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Loki
        type: loki
        access: proxy
        url: http://loki-gateway.loki.svc.cluster.local
        isDefault: false
        jsonData:
          maxLines: 1000

      - name: Tempo
        type: tempo
        access: proxy
        url: http://tempo-gateway.tempo.svc.cluster.local
        basicAuth: false

      - name: Mimir
        type: prometheus
        access: proxy
        url: http://mimir-nginx.mimir.svc.cluster.local:80/prometheus
        isDefault: true
        jsonData:
          prometheusType: Mimir
          

  VALUES
  }

  loki = {
    values: <<-VALUES
loki:
    auth_enabled: false
    schemaConfig:
        configs:
        - from: "2024-04-01"
          store: tsdb
          object_store: s3
          schema: v13
          index:
            prefix: loki_index_
            period: 24h
    storage_config:
        aws:
            region: ${var.region}
            bucketnames: ${aws_s3_bucket.loki-chunks.id}
            s3forcepathstyle: false
    storage:
        type: s3
        bucketNames:
            chunks: ${aws_s3_bucket.loki-chunks.id}
            ruler: ${aws_s3_bucket.loki-ruler.id}
            admin: ${aws_s3_bucket.loki-admin.id}
    ingester:
        chunk_encoding: snappy
    querier:
        # Default is 4, if you have enough memory and CPU you can increase, reduce if OOMing
        max_concurrent: 4
    pattern_ingester:
        enabled: true
    limits_config:
        allow_structured_metadata: true
        volume_enabled: true
        retention_period: 672h

deploymentMode: SimpleScalable

backend:
    replicas: 3
    persistence:
        storageClass: gp3

    nodeSelector:
        karpenter.sh/nodepool: loki

read:
    replicas: 3

    nodeSelector:
        karpenter.sh/nodepool: loki

write:
    replicas: 3 # To ensure data durability with replication
    persistence:
        storageClass: gp3

    nodeSelector:
        karpenter.sh/nodepool: loki        

gateway:
    replicas: 3
    service:
        type: NodePort

    nodeSelector:
        karpenter.sh/nodepool: loki

minio:
    enabled: false

    VALUES
  }

    tempo = {
        values: <<-VALUES
storage:
    trace:
        backend: s3
        s3:
            bucket: ${aws_s3_bucket.tempo.id}
            region: ${var.region}
            endpoint: s3.amazonaws.com
            forcepathstyle: false
gateway:
    enabled: true
    replicas: 3
    service:
        type: NodePort
    nodeSelector:
        karpenter.sh/nodepool: tempo
queryFrontend:
    replicas: 3
    query:
        enabled: false
    nodeSelector:
        karpenter.sh/nodepool: tempo       
querier:
    replicas: 3
    nodeSelector:
        karpenter.sh/nodepool: tempo       
distributor:
    enabled: true
    replicas: 3
    nodeSelector:
        karpenter.sh/nodepool: tempo           
ingester:
    replicas: 3
    nodeSelector:
        karpenter.sh/nodepool: tempo     
compactor:
    replicas: 3
    nodeSelector:
        karpenter.sh/nodepool: tempo       
traces:
    otlp:
        http:
            enabled: true
    grpc:
        enabled: true
    VALUES
    }


mimir = {
        values: <<-VALUES
enterprise:
    enabled: false
graphite:
    enabled: false
mimir:
  structuredConfig:
    limits:
      max_label_names_per_series: 50
      max_global_series_per_user: 150000000
    common:
      storage:
        backend: s3
        s3:
          endpoint: s3.${var.region}.amazonaws.com
          bucket_name: ${aws_s3_bucket.mimir.id}
          insecure: false
    blocks_storage:
      backend: s3
      s3:
        endpoint: s3.${var.region}.amazonaws.com
        bucket_name: ${aws_s3_bucket.mimir.id}
        insecure: false
    ruler_storage:
      backend: s3
      s3:
        endpoint: s3.${var.region}.amazonaws.com
        bucket_name: ${aws_s3_bucket.mimir_ruler.id}
        insecure: false

alertmanager:
  enabled: false

compactor:
  persistentVolume:
    storageClass: gp3
    size: 20Gi
  resources:
    limits:
      memory: 2Gi
    requests:
      cpu: 1
      memory: 1Gi
  nodeSelector:
    karpenter.sh/nodepool: mimir  
    
distributor:
  replicas: 3
  resources:
    limits:
      memory: 5.7Gi
    requests:
      cpu: 2
      memory: 4Gi
  nodeSelector:
    karpenter.sh/nodepool: mimir
  persistence:
    storageClass: gp3

ingester:
  persistentVolume:
    storageClass: gp3
    size: 50Gi
  replicas: 3
  resources:
    limits:
      memory: 10Gi
    requests:
      cpu: 2
      memory: 4Gi
  nodeSelector:
    karpenter.sh/nodepool: mimir

  zoneAwareReplication:
    enabled: false

admin-cache:
  enabled: false
  replicas: 3

chunks-cache:
  enabled: true
  replicas: 3
  nodeSelector:
    karpenter.sh/nodepool: mimir  
  persistence:
    storageClass: gp3

index-cache:
  enabled: true
  replicas: 3
  nodeSelector:
    karpenter.sh/nodepool: mimir  
  persistence:
    storageClass: gp3

metadata-cache:
  enabled: true
  replicas: 3
  nodeSelector:
    karpenter.sh/nodepool: mimir  
  persistence:
    storageClass: gp3

results-cache:
  enabled: true
  replicas: 3
  nodeSelector:
    karpenter.sh/nodepool: mimir  
  persistence:
    storageClass: gp3

minio:
  enabled: false

overrides_exporter:
  replicas: 1
  resources:
    limits:
      memory: 128Mi
    requests:
      cpu: 100m
      memory: 128Mi
querier:
  replicas: 1
  resources:
    limits:
      memory: 6Gi
    requests:
      cpu: 2
      memory: 4Gi
  nodeSelector:
    karpenter.sh/nodepool: mimir  
query_frontend:
  replicas: 1
  resources:
    limits:
      memory: 3Gi
    requests:
      cpu: 2
      memory: 2Gi
  nodeSelector:
    karpenter.sh/nodepool: mimir  
ruler:
  replicas: 1
  serviceAccount:
    create: true
  resources:
    limits:
      memory: 3Gi
    requests:
      cpu: 1
      memory: 2Gi
  nodeSelector:
    karpenter.sh/nodepool: mimir  
store_gateway:
  persistentVolume:
    storageClass: gp3
    size: 10Gi
  replicas: 3
  resources:
    limits:
      memory: 2Gi
    requests:
      cpu: 1
      memory: 1Gi
  nodeSelector:
    karpenter.sh/nodepool: mimir  
  topologySpreadConstraints: {}
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: target # support for enterprise.legacyLabels
                operator: In
                values:
                  - store-gateway
          topologyKey: 'kubernetes.io/hostname'
        - labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/component
                operator: In
                values:
                  - store-gateway
          topologyKey: 'kubernetes.io/hostname'
  zoneAwareReplication:
    topologyKey: 'kubernetes.io/hostname'

nginx:
  replicas: 3
  resources:
    limits:
      memory: 1Gi
    requests:
      cpu: 1
      memory: 512Mi
  service:
    type: NodePort
  nodeSelector:
    karpenter.sh/nodepool: mimir

gateway:
  replicas: 3
  resources:
    limits:
      memory: 1Gi
    requests:
      cpu: 1
      memory: 512Mi
  nodeSelector:
    karpenter.sh/nodepool: mimir

    VALUES
    }

}