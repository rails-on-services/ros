deploymentStrategy: Recreate
persistence:
  enabled: true
resources:
  limits:
    memory: 1.2Gi
  requests:
    cpu: 0.3
    memory: 1Gi
adminPassword: ${admin_password}
datasources:
 datasources.yaml:
   apiVersion: 1
   datasources:
   - name: Prometheus
     type: prometheus
     url: http://prometheus.istio-system:9090
     access: proxy
     isDefault: true
sidecar:
  skipTlsVerify: true
  dashboards:
    enabled: true
    label: ${cm_dashboard_label}
    searchNamespace: ALL
