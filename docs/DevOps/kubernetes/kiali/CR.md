```yaml

spec:
  external_services:
    grafana:
      enabled: true
      # Grafana service name is "grafana" and is in the "telemetry" namespace.
      in_cluster_url: 'http://grafana.telemetry:3000/'
      # Public facing URL of Grafana
      url: 'http://my-ingress-host/grafana'
      dashboards:
      - name: "Istio Service Dashboard"
        variables:
          namespace: "var-namespace"
          service: "var-service"
      - name: "Istio Workload Dashboard"
        variables:
          namespace: "var-namespace"
          workload: "var-workload"
      - name: "Istio Mesh Dashboard"
      - name: "Istio Control Plane Dashboard"
      - name: "Istio Performance Dashboard"
      - name: "Istio Wasm Extension Dashboard"

```