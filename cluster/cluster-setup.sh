# /bin/bash --login

# kill on error or SIGTERM
set -e
trap 'kill -TERM $PID' TERM INT

# cert manager
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i cert-manager jetstack/cert-manager -n cert-manager --create-namespace --version 'v1.12.1' --set installCRDs=true

# k8s metrics server (some k8s providers have this pre-installed)
# helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
# helm upgrade -i metrics-server metrics-server/metrics-server -n kube-system --version '3.10.0'

# cluster autoscaler (cloud-dependent): https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
# helm repo add autoscaler https://kubernetes.github.io/autoscaler
# helm upgrade -i cluster-autoscaler autoscaler/cluster-autoscaler -n kube-system

# k8s dashboard; for access, see https://github.com/kubernetes/dashboard#access
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Elastic search for logging
# ECK operator: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-install-helm.html
helm repo add elastic https://helm.elastic.co
helm upgrade -i elastic-operator elastic/eck-operator -n elastic-system --create-namespace --version '2.8.0'
# then install ECK stack for logging: https://artifacthub.io/packages/helm/elastic/eck-stack
# TODO ugh wants license wow the fuck https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-licensing.html#k8s-add-license
# https://github.com/elastic/cloud-on-k8s/issues/6261
helm upgrade -i eck-stack elastic/eck-stack -n elastic-stack --create-namespace --version '0.5.0' -f ./cluster/eck-stack-values.yaml

# prometheus for monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace --version '46.8.0'
# adapter for k8s HPA custom metrics
helm upgrade -i prom-adapter prometheus-community/prometheus-adapter -n monitoring --version '4.2.0'
# pushgateway
helm upgrade -i prom-pushgateway prometheus-community/prometheus-pushgateway -n monitoring --version '2.2.0' -f ./cluster/pushgateway-values.yaml
