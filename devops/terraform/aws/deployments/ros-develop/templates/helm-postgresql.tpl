image:
  repository: mdillon/postgis
  tag: 10
fullnameOverride: postgres
postgresqlUsername: ${postgres_user}
postgresqlPassword: ${postgres_password}
postgresqlDatabase: ${postgres_db}
postgresqlDataDir: /data/pgdata
persistence:
  enabled: true
  mountPath: /data/
  existingClaim: ${pvc}
securityContext:
  enabled: false
resources: ${resources}
