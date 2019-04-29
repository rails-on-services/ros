apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: istio-alb-ingressgateway
  namespace: istio-system
  annotations:
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig":{"Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    alb.ingress.kubernetes.io/load-balancer-attributes: 'idle_timeout.timeout_seconds=300'
    alb.ingress.kubernetes.io/backend-protocol: 'HTTP'
    alb.ingress.kubernetes.io/certificate-arn: '${acm_cert_arn}'
    alb.ingress.kubernetes.io/healthcheck-path: '/healthz/ready'
    alb.ingress.kubernetes.io/healthcheck-port: '15020'
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80},{"HTTPS": 443}]'
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    kubernetes.io/ingress.class: alb
spec:
  backend:
    serviceName: istio-ingressgateway
    servicePort: 80
  rules:
  - http:
      paths:
      - backend:
          serviceName: ssl-redirect
          servicePort: use-annotation
        path: /*
