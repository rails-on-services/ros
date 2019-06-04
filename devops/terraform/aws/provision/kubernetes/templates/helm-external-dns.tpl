aws:
  region: ${aws_region}
  zoneType: ${zoneType}
provider: aws
rbac:
  create: true
domainFilters: ${domainFilters}
zoneIdFilters: ${zoneIdFilters}
resources:
  requests:
    cpu: 0.1
    memory: 128Mi
policy: sync
