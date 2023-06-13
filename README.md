# K0s cluster

Private Kubernetes cluster setup on a home lab using [k0sctl](https://github.com/k0sproject/k0sctl) and Helm charts.

## Installation

First install the prerequisites:

```bash
# install kubectl, helm
brew install kubectl helm
# install k0sctl for cluster setup
brew install k0sproject/tap/k0sctl
```

## Usage

### Setup K8s Cluster

> See detailed blog post [Setup a private Kubernetes cluster with k0sctl](https://kengz.gitbook.io/blog/setting-up-a-private-kubernetes-cluster-with-k0sctl)

Inspect/configure [./cluster/k0sctl.yaml](./cluster/k0sctl.yaml) and run:

```bash
k0sctl apply --config cluster/k0sctl.yaml
# save kubeconfig
k0sctl kubeconfig --config cluster/k0sctl.yaml > ~/.kube/config && chmod go-r ~/.kube/config
k get nodes
# make openebs-hostpath the default storage class
kubectl patch storageclass openebs-hostpath -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

To reset:

```bash
k0sctl reset --config cluster/k0sctl.yaml
```

### Install Cluster Addons

> See detailed blog post [Setting up Kubernetes Addons](https://kengz.gitbook.io/blog/setting-up-kubernetes-addons).

Install the cluster components with Helm:

Loki (scalable): to aggregate and index all logs in the cluster, with retention policy; the logs are searchable in Grafana. Additionally:
promtail to aggregate logs
Note: Elasticsearch charts (hence ELK) have been deprecated in favor of their licensed ECK; plus Loki is much easier to run and maintain
kube-prometheus-stack: for cluster monitoring with many useful preconfigured cluster Prometheus metrics in Grafana dashboards. Additionally:
prometheus-adapter for custom metrics API, e.g. for HPA to scale using custom-defined metrics.
Prometheus Pushgateway to push application metrics
Blackbox Exporter to probe endpoints for uptime monitoring

- [cert-manager](https://cert-manager.io/docs/installation/helm/): certificate management
- [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler): to dynamically autoscale cluster by adding or reducing nodes
- [metrics-server](https://github.com/kubernetes-sigs/metrics-server/tree/master/charts/metrics-server): for monitoring and and HPA (HorizontalPodAutoscaler) to work
- [kubernetes-dashboard](https://github.com/kubernetes/dashboard#access): basic cluster monitoring (if Lens is not available)
- [Loki (scalable)](https://github.com/grafana/loki/tree/main/production/helm/loki) to aggregate and index all logs in the cluster, with retention policy; the logs are searchable in Grafana. Additionally:
  - [promtail](https://grafana.com/docs/loki/latest/clients/promtail/) to aggregate logs
  - Note: [Elasticsearch charts](https://github.com/elastic/helm-charts) (hence ELK) have been deprecated in favor of their licensed ECK; plus Loki is much easier to run and maintain
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster monitoring with many useful preconfigured cluster Prometheus metrics in Grafana dashboards. Additionally:
  - [prometheus-adapter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-adapter) for custom metrics API, e.g. for HPA to scale using custom-defined metrics.
  - [prometheus-pushgateway](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-pushgateway) to push application metrics
  - [prometheus-blackbox-exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter) to probe endpoints for uptime monitoring

```bash
bash ./cluster/cluster-addons.sh
```

Additionally, install [Lens](https://k8slens.dev) for GUI monitoring and access to the cluster. Get a free license to use.

### Accessing Dashboards

> See more on blog post [Setting up Kubernetes Addons](https://kengz.gitbook.io/blog/setting-up-kubernetes-addons).

- [Lens](https://k8slens.dev)
  - just open the app, it will use `~/.kube/config` to connect
- [Kubernetes Dashboard](https://github.com/kubernetes/dashboard#access)
  - get token: `kubectl -n kubernetes-dashboard create token admin-user`
  - run `kubectl proxy` and visit http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
- [Grafana](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster and logging monitoring
  - data sources include kube-state-metrics, node-exporter, prometheus, and custom-added loki for logs
  - run `kubectl port-forward -n monitoring svc/prometheus-grafana 6060:80` and visit http://localhost:6060 to find the preconfigured dashboards
  - (one-time) [import](https://grafana.com/docs/grafana/latest/dashboards/manage-dashboards/#import-a-dashboard) this [Loki Kubernetes Logs](https://grafana.com/grafana/dashboards/15141-kubernetes-service-logs/) and this [Blackbox exporter](https://grafana.com/grafana/dashboards/7587-prometheus-blackbox-exporter/) dashboards
- [Prometheus](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster monitoring
  - run `kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090` and visit http://localhost:9090

### Troubleshoot

- delete pod stuck in terminating state:
  ```bash
  kubectl delete pod --grace-period=0 --force <PODNAME>
  ```
- decode secret:
  ```bash
  kubectl get secret <SECRETNAME> -n <NAMESPACE> -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```
