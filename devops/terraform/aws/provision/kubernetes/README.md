# Terraform script to create Kubernetes Infrastructure on AWS

This terraform script creates a basic infrastructure on AWS that consists of:

* Basic VPC resources:
  - VPC
  - subnets
  - Internete Gateway
  - NAT Gateway
  - etc
* Route53 Hosted Zone for the subdomain you specified
* AWS ACM wildcard certificate for the subdomain you specified
* EKS Cluster
  - One worker auto scaling group
  - Tiller initialized
  - Helm releases including:
    - cluster-autoscaler
    - metrics-server
    - aws-alb-ingress-controller
    - istio
    - Ingress with ALB for istio ingress gateway
    - A public accessible grafana

## Grafana

Grafana is configured with the prometheus deployed by istio as default data source. The initial password for the admin user need to be specified by variable `grafana_dashboards_configmap_label`.

Grafana's public hostname is composed as `grafana-hostname`.`route53_zone_this_name`.`route53_zone_main_name`.

### Grafana Dashboards

Grafana deployment is configured to auto discovery dashboard definitions created as kubernetes configMap. It only load configMaps having label name equal to variable `grafana_dashboards_configmap_label`.

For example, to create a grafana dashboard and load into the grafana, one can save the grafana dashbaord json to a local file named as `grafana-sample-dashboard.json`. Then he create a configMap by:

```shell
kubectl create configmap grafana-sample-dashboard --from-file grafana-sample-dashboard.json
```

Then label the configmap with key matching variable `grafana_dashboards_configmap_label`. Assume using default value which is grafana_dashboard.

```shell
# the label value doesn't matter, here we are using true
kubectl label configmap grafana-sample-dashboard grafana_dashboard=true
```

And refresh grafana, the dashboard should appear.
