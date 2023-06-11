# K0s cluster

Private Kubernetes cluster setup on a home lab.

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

- [Setup a private Kubernetes cluster with k0sctl](https://kengz.gitbook.io/blog/setting-up-a-private-kubernetes-cluster-with-k0sctl) (Note: use [./cluster/k0sctl.yaml](./cluster/k0sctl.yaml)):

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

Install the cluster components with Helm:

- [cert-manager](https://cert-manager.io/docs/installation/helm/)
- [cluster-autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [metrics-server](https://github.com/kubernetes-sigs/metrics-server/tree/master/charts/metrics-server)
- [kubernetes-dashboard](https://github.com/kubernetes/dashboard#access)
- [Grafana Loki-stack](https://github.com/grafana/helm-charts/tree/main/charts/loki-stack) for logging
  - [Elasticsearch charts](https://github.com/elastic/helm-charts) (hence ELK) have been deprecated in favor of their licensed ECK; plus Loki is much easier to run and maintain
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster monitoring

```bash
bash ./cluster/cluster-addons.sh
```

Additionally, install [Lens](https://k8slens.dev) for GUI monitoring and access to the cluster. Get a free license to use.

### Accessing Dashboards

- [Lens](https://k8slens.dev)
  - just open the app, it will use `~/.kube/config` to connect
- [Kubernetes Dashboard](https://github.com/kubernetes/dashboard#access)
  - get token: `kubectl -n kubernetes-dashboard create token admin-user`
  - run `kubectl proxy` and visit http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
- [loki-grafana](https://github.com/grafana/helm-charts/tree/main/charts/loki-stack) for logging
  - username is `admin`
  - get password: `kubectl get secret loki-grafana -n logging -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`
  - run `kubectl port-forward -n logging svc/loki-grafana 7070:80` and visit http://localhost:7070
- [prometheus-grafana](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster monitoring
  - username is `admin`, password is `prom-operator`
  - run `kubectl port-forward -n monitoring svc/prometheus-grafana 6060:80` and visit http://localhost:6060 to find the preconfigured dashboards
- [prometheus](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) for cluster monitoring
  - run `kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090` and visit http://localhost:9090

### Weaviate

Install [Weaviate vector database](https://weaviate.io/developers/weaviate/installation/kubernetes) using local values file and:

```bash
k create namespace weaviate
kcn weaviate
# install weaviate
helm upgrade -i weaviate weaviate/weaviate -n weaviate -f ./weaviate/values.yaml
```

### Troubleshoot

- delete pod stuck in terminating state:
  ```bash
  kubectl delete pod <PODNAME> --grace-period=0 --force
  ```
- decode secret:
  ```bash
  kubectl get secret loki-grafana -n logging -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  ```
