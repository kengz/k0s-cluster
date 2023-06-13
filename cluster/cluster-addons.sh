# /bin/bash --login

# echo cmd; kill on error or SIGTERM
set -x -e
trap 'kill -TERM $PID' TERM INT

# cert manager
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager jetstack/cert-manager -n cert-manager --create-namespace --version 'v1.12.1' --set installCRDs=true

# cluster autoscaler (cloud-dependent): https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
# helm repo add autoscaler https://kubernetes.github.io/autoscaler
# helm upgrade -i cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system

# k8s metrics server (some k8s providers have this pre-installed)
# helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
# helm upgrade -i metrics-server metrics-server/metrics-server -n kube-system --version '3.10.0'

# k8s dashboard; in general, use Lens https://k8slens.dev (free for personal)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl apply -f ./cluster/dashboard-admin-user.yaml

# use Loki (scalable) for logging (Grafana included with kube-prometheus-stack)
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade -i loki grafana/loki -n logging --create-namespace --version '5.6.4' -f ./cluster/loki-values.yaml
helm upgrade -i promtail grafana/promtail -n logging --version '6.11.3'

# Prometheus for cluster monitoring (includes Grafana)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace --version '46.8.0' -f ./cluster/prometheus-values.yaml
# adapter for k8s HPA custom metrics
helm upgrade -i prom-adapter prometheus-community/prometheus-adapter -n monitoring --version '4.2.0'
# pushgateway for app metrics
helm upgrade -i prom-pushgateway prometheus-community/prometheus-pushgateway -n monitoring --version '2.2.0' -f ./cluster/pushgateway-values.yaml
# blackbox exporter for uptime monitoring
helm install blackbox prometheus-community/prometheus-blackbox-exporter -n monitoring --version '7.10.0' -f ./cluster/blackbox-values.yaml
