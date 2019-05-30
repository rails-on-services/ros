apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: grafana-gateway
  labels:
    app.kubernetes.io/name: grafana-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
      - ${host}

---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana
  labels:
    app.kubernetes.io/name: grafana
spec:
  hosts:
    - ${host}
  gateways:
    - grafana-gateway
  http:
    - route:
      - destination:
          host: grafana
          port:
            number: 80
