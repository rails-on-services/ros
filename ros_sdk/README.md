
# RosSdk


## Configuration

```yaml
# This service's specific configuration; calculate URNs, etc
service:
  # name is set by the service
  # name:
  # policy_name is set by the service
  # policy_name:
  partition_name: ros
  region: ''
  auth_type: Internal
connection_type: port
external_connection_type: path
# The options for configuring internal connections to services
# TODO: Change ot service_connection_types
services:
  connection:
    type: port
    # 'host' is the default. Each service runs on port 3000 and is uniquely
    # addressed by it's host name which is taken from the module name of the Client
    # Can override values here with an ENV. For example, to use https instead of http:
    # export PLATFORM__SERVICES__CONNECTION__TYPE=host
    # export PLATFORM__SERVICES__CONNECTION__HOST__SCHEME=https
    host:
      scheme: http
      port: 3000
    # port based means that each configured service has its own port on localhost
    # port number starts at value of 'port' and increments by 1 for each additional service
    # The port to service mapping is in alphabetical order by the service name
    # e.g. 'comm' is a lower port number than 'iam'
    # To use this connection type:
    # export PLATFORM__SERVICES__CONNECTION__TYPE=port
    port:
      scheme: http
      host: localhost
      port: 3000
jwt:
  iss: ros
  alg: HS256
```
