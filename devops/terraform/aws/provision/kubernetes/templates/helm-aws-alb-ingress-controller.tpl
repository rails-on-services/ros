clusterName: ${cluster_name}
autoDiscoverAwsRegion: true
autoDiscoverAwsVpcID: true
image:
  tag: v1.1.1
enableReadinessProbe: true
enableLivenessProbe: true
resources:
  requests:
    cpu: 0.3
    memory: 512Mi
scope:
  ingressClass: alb
extraArgs:
  feature-gates: 'waf=false'
