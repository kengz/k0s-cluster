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
mkdir -p ~/.kube
k0sctl kubeconfig --config cluster/k0sctl.yaml > ~/.kube/config
chmod go-r ~/.kube/config
k get nodes
```

- Install [Ceph Cluster via Helm chart](https://rook.io/docs/rook/v1.11/Helm-Charts/helm-charts/) for storage:

```bash
https://rook.io/docs/rook/v1.11/Helm-Charts/operator-chart/#installing
helm repo add rook-release https://charts.rook.io/release
helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph
helm install --create-namespace --namespace rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster
```

### Weaviate

Install [Weaviate vector database](https://weaviate.io/developers/weaviate/installation/kubernetes) using local values file and:

```bash
k create namespace weaviate
kcn weaviate
# create PV so helm chart below can use it for PVC
kaf weaviate/pv.yaml
# install weaviate
helm upgrade -i weaviate weaviate/weaviate -n weaviate -f ./weaviate/values.yaml
```

## TODO

- do without hostpath in PV
- dynamic pv across nodes
- actually do k0s EBS
