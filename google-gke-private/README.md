**-- WORK IN PROGRESS - DO NOT USE --**  
     
     
    
    
    
# How to install Ondat on a private Google GKE cluster
This how-to provides a comprehensive overview of the necessary steps to deploy Ondat on a private GKE cluster - private clusters means not access to the internet including container registries like Docker Hub. 

## Requirements
The following requirements are needed for a successful deployment of Ondat on a private GKE cluster:
- a deployed private GKE cluster
- an access to the private GKE cluster via the Google Cloud Shell
- an Google Artifact Registry within the same region as the GKE cluster 

## Setup Artifact Registry with the Ondat container images
From the Google Cloud Shell, here is an example to retrieve the ```storageos/node``` container image:

first, login to the Google Artifact Registry to validate and deploy the necessary credentials: 
```
gcloud auth configure-docker us-central1-docker.pkg.dev
```
then pull the original image from Docker Hub:
```
docker pull storageos/node:v2.5.0-beta.1
```
then retag the image towards your private Artifact Registry:
```
docker tag docker.io/storageos/node:v2.5.0-beta.1 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/node:v2.5.0-beta.1
```
and finally, push the retag image to the Google Artifact Registry:
```
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/node:v2.5.0-beta.1
```

Repeat the process for the remaining images as such:

first pull the images:
```
docker pull storageos/api-manager:v2.5.0-sync
docker pull storageos/init:v2.1.0
docker pull quay.io/k8scsi/csi-node-driver-registrar:v2.1.0
docker pull storageos/csi-provisioner:v2.1.1-patched
docker pull quay.io/k8scsi/csi-attacher:v3.1.0
docker pull quay.io/k8scsi/csi-resizer:v1.1.0
docker pull quay.io/k8scsi/livenessprobe:v2.2.0
docker pull k8s.gcr.io/kube-scheduler:v1.20.5
docker pull storageos/operator:v2.5.0-beta.1
docker pull storageos/operator-manifests:v2.5.0-beta.1
docker pull quay.io/brancz/kube-rbac-proxy:v0.10.0
```
then retag the images:
```
docker tag storageos/api-manager:v2.5.0-sync us-central1-docker.pkg.dev/shaped-complex-318513/ondat/api-manager:v2.5.0-sync
docker tag storageos/init:v2.1.0 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/init:v2.1.0
docker tag quay.io/k8scsi/csi-node-driver-registrar:v2.1.0 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-node-driver-registrar:v2.1.0
docker tag storageos/csi-provisioner:v2.1.1-patched us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-provisioner:v2.1.1-patched
docker tag quay.io/k8scsi/csi-attacher:v3.1.0 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-attacher:v3.1.0
docker tag quay.io/k8scsi/csi-resizer:v1.1.0 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-resizer:v1.1.0
docker tag quay.io/k8scsi/livenessprobe:v2.2.0 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/livenessprobe:v2.2.0
docker tag k8s.gcr.io/kube-scheduler:v1.20.5 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/kube-scheduler:v1.20.5
docker tag storageos/operator:v2.5.0-beta.1 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/operator:v2.5.0-beta.1
docker tag storageos/operator-manifests:v2.5.0-beta.1 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/operator-manifests:v2.5.0-beta.1
docker tag quay.io/brancz/kube-rbac-proxy:v0.10.0 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/kube-rbac-proxy:v0.10.0
```
finally, push the container images:
```
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/api-manager:v2.5.0-sync
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/init:v2.1.0
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-node-driver-registrar:v2.1.0
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-provisioner:v2.1.1-patched
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-attacher:v3.1.0
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-resizer:v1.1.0
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/livenessprobe:v2.2.0
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/kube-scheduler:v1.20.5
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/operator:v2.5.0-beta.1
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/operator-manifests:v2.5.0-beta.1
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/kube-rbac-proxy:v0.10.0
```

## Setup the CRD to deploy Ondat using the Google Artifact Registry
When deploying in an airgap environment, the following CRs will be mofidied to target the Google Artifact Rregistry: 
```YAML
---
# Secret
apiVersion: v1
kind: Secret
metadata:
  name: storageos-api
  namespace: storageos
  labels:
    app: storageos
type: Opaque
data:
  password: c3RvcmFnZW9z # echo -n <username> | base64
  username: c3RvcmFnZW9z # echo -n <username> | base64
---
# CR cluster definition
apiVersion: storageos.com/v1
kind: StorageOSCluster
metadata:
  name: storageos-cluster
  namespace: "storageos"
spec:
  secretRefName: "storageos-api"
  secretRefNamespace: "storageos"
  k8sDistro: "upstream"
  storageClassName: storageos
  images:
    nodeContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/node:v2.5.0-beta.1
    apiManagerContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/api-manager:v2.5.0-sync
    initContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/init:v2.1.0
    csiNodeDriverRegistrarContainer: qus-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-node-driver-registrar:v2.1.0
    csiExternalProvisionerContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-provisioner:v2.1.1-patched
    csiExternalAttacherContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-attacher:v3.1.0
    csiExternalResizerContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-resizer:v1.1.0
    csiLivenessProbeContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/livenessprobe:v2.2.0
    kubeSchedulerContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/kube-scheduler:v1.20.5
  kvBackend:
    address: "storageos-etcd-client.storageos-etcd:2379"
  resources:
    requests:
      memory: "1Gi"
      cpu: 1
#  nodeSelectorTerms:
#    - matchExpressions:
#      - key: "node-role.kubernetes.io/worker" # Compute node label will vary according to your installation
#        operator: In
#        values:
#        - "true"
```

kubectl storageos install --include-etcd --etcd-namespace storageos --stos-cluster-yaml ondat-cluster.yaml --stos-version v2.5.0-beta.1