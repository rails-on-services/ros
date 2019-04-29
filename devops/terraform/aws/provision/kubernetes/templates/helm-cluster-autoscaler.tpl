rbac:
  create: true

sslCertPath: /etc/ssl/certs/ca-bundle.crt

cloudProvider: aws
awsRegion: ${aws_region}

autoDiscovery:
  clusterName: ${cluster_name}
  enabled: true

extraArgs:
  skip-nodes-with-local-storage: false
