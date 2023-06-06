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

To reset:

```bash
k0sctl reset --config cluster/k0sctl.yaml
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
