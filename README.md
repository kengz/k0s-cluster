# K0s cluster

Private Kubernetes cluster setup on home lab.

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

- [Setup a private Kubernetes cluster with k0sctl](https://kengz.gitbook.io/blog/setting-up-a-private-kubernetes-cluster-with-k0sctl) (Note: use [cluster/k0sctl.yaml](./cluster/k0sctl.yaml)):

```bash
k0sctl apply --config cluster/k0sctl.yaml
# save kubeconfig
k0sctl kubeconfig --config cluster/k0sctl.yaml > ~/.kube/config
chmod go-r ~/.kube/config
k get nodes
```

- Install [Ceph Cluster via Helm chart](https://rook.io/docs/rook/v1.11/Helm-Charts/helm-charts/) for storage:

```bash
helm repo add rook-release https://charts.rook.io/release
helm upgrade -i --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph -f cluster/rook-values.yaml
helm install --create-namespace --namespace rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster
kubectl --namespace rook-ceph get cephcluster
```

### Weaviate

Install [Weaviate vector database](https://weaviate.io/developers/weaviate/installation/kubernetes) using local values file and:

```bash
k create namespace weaviate
kcn weaviate
# install weaviate
helm upgrade -i weaviate weaviate/weaviate -n weaviate -f ./weaviate/values.yaml
```

## TODO

- do without hostpath in PV
- dynamic pv across nodes
- actually do k0s EBS
