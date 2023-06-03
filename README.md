# K0s cluster

Private Kubernetes cluster setup.

## Installation

First install the prerequisites:

```bash
# install kubectl, helm
brew install kubectl helm
# install k0sctl for cluster setup
brew install k0sproject/tap/k0sctl
```

## Usage

- [Setup a private Kubernetes cluster with k0sctl](https://kengz.gitbook.io/blog/setting-up-a-private-kubernetes-cluster-with-k0sctl) (Note: use [cluster/k0sctl.yaml](./cluster/k0sctl.yaml))
- if you created `controller+worker` role from k0s, untaint master node(s) to make schedulable: `k taint nodes --all node-role.kubernetes.io/master-`
- create local storage class: `kaf ./cluster/storage.yaml`

```bash
k0sctl apply --config cluster/k0sctl.yaml
# save kubeconfig
mkdir -p ~/.kube
k0sctl kubeconfig --config cluster/k0sctl.yaml > ~/.kube/config
k get nodes
```

Continue setup below.

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
