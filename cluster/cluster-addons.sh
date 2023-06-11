# /bin/bash --login

# kill on error or SIGTERM
set -e
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

# use Grafana Loki stack for logging
helm repo add grafana https://grafana.github.io/helm-charts
helm upgrade -i loki grafana/loki-stack -n logging --create-namespace --version '2.9.10' -f ./cluster/loki-values.yaml

# prometheus for monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace --version '46.8.0'
# adapter for k8s HPA custom metrics
helm upgrade -i prom-adapter prometheus-community/prometheus-adapter -n monitoring --version '4.2.0'
# pushgateway
helm upgrade -i prom-pushgateway prometheus-community/prometheus-pushgateway -n monitoring --version '2.2.0' -f ./cluster/pushgateway-values.yaml
