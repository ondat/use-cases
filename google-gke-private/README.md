**-- WORK IN PROGRESS - DO NOT USE --**  
     
     
    
    

# How to install Ondat on a private Google GKE cluster
This how-to provides a comprehensive overview of the necessary steps to deploy Ondat on a private GKE cluster - private clusters means not access to the internet including container registries like Docker Hub. 

## Requirements
The following requirements are needed for a successful deployment of Ondat on a private GKE cluster:
- a deployed private GKE cluster
- an access to the private GKE cluster via the Google Cloud Shell
- an Google Artifact Registry within the same region as the GKE cluster 
- have the [Ondat storageos kubectl plugin](https://docs.ondat.io/v2.5/docs/install/kubernetes/#install-the-storageos-kubectl-plugin) deployed on the Google Cloud Shell

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
docker pull storageos/etcd-cluster-operator-controller:v0.3.1
docker pull storageos/etcd-cluster-operator-proxy:v0.3.1
docker pull quay.io/coreos/etcd:v3.5.0
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
docker tag storageos/etcd-cluster-operator-controller:v0.3.1 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd-cluster-operator-controller:v0.3.1
docker tag storageos/etcd-cluster-operator-proxy:v0.3.1 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd-cluster-operator-proxy:v0.3.1
docker tag quay.io/coreos/etcd:v3.5.0 us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd:v3.5.0
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
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd-cluster-operator-controller:v0.3.1 
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd-cluster-operator-proxy:v0.3.1
docker push us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd:v3.5.0
```

## Setup the CRD to deploy Ondat using the Google Artifact Registry
The following dedicated manifest are required to full deploy Ondat with the internal etcd cluster:
- ```ondat-etcd-operator.yaml```
- ```ondat-etcd-cluster.yaml```
- ```ondat-operator.yaml```
- ```ondat-cluster.yaml```

### ondat-etcd-operator.yaml
The most of this file doesn't need any modication about for the last 2 Deployment entries within:

- ```containers``` for the ```storage-etcd-controller-manager``` by adding ```--etcd-repository=us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd``` as an extra ```args```
- modifying both ```image``` parameters by adding the path to your internal custom registry, in this case ```us-central1-docker.pkg.dev/shaped-complex-318513/ondat/```

```YAML
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    control-plane: controller-manager
  name: storageos-etcd-controller-manager
  namespace: storageos-etcd
spec:
  replicas: 1
  selector:
    matchLabels:
      control-plane: controller-manager
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
      labels:
        control-plane: controller-manager
    spec:
      containers:
      - args:
        - --enable-leader-election
        - --proxy-url=storageos-proxy.storageos-etcd.svc
        - --etcd-repository=us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd
        command:
        - /manager
        env:
        - name: DISABLE_WEBHOOKS
          value: "true"
        image: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd-cluster-operator-controller:v0.3.1
        name: manager
        ports:
        - containerPort: 8080
          name: metrics
          protocol: TCP
        resources:
          limits:
            cpu: 100m
            memory: 100Mi
          requests:
            cpu: 100m
            memory: 100Mi
      terminationGracePeriodSeconds: 10
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    control-plane: proxy
  name: storageos-etcd-proxy
  namespace: storageos-etcd
spec:
  replicas: 1
  selector:
    matchLabels:
      control-plane: proxy
  template:
    metadata:
      labels:
        control-plane: proxy
    spec:
      containers:
      - args:
        - --api-port=8080
        image: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/etcd-cluster-operator-proxy:v0.3.1
        name: proxy
        resources:
          limits:
            cpu: 100m
            memory: 50Mi
          requests:
            cpu: 100m
            memory: 50Mi
      terminationGracePeriodSeconds: 10
```

### ondat-etcd-cluster.yaml 
Nothing to modify here except if request by Ondat Customer Success Team.

### ondat-operator.yaml
This file containers multiple entries related to image registries like: 

```YAML
apiVersion: v1
data:
  RELATED_IMAGE_API_MANAGER: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/api-manager:v1.2.0
  RELATED_IMAGE_CSIV1_EXTERNAL_ATTACHER_V3: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/k8scsi/csi-attacher:v3.1.0
  RELATED_IMAGE_CSIV1_EXTERNAL_PROVISIONER: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-provisioner:v2.1.1-patched
  RELATED_IMAGE_CSIV1_EXTERNAL_RESIZER: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-resizer:v1.1.0
  RELATED_IMAGE_CSIV1_LIVENESS_PROBE: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/livenessprobe:v2.2.0
  RELATED_IMAGE_CSIV1_NODE_DRIVER_REGISTRAR: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-node-driver-registrar:v2.1.0
  RELATED_IMAGE_STORAGEOS_INIT: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/init:v2.1.0
  RELATED_IMAGE_STORAGEOS_NODE: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/node:v2.5.0-beta.1
```

```YAML
---
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    kubectl.kubernetes.io/default-logs-container: manager
  labels:
    app: storageos
    app.kubernetes.io/component: operator
    control-plane: storageos-operator
  name: storageos-operator
  namespace: storageos
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storageos
      app.kubernetes.io/component: operator
      control-plane: storageos-operator
  template:
    metadata:
      labels:
        app: storageos
        app.kubernetes.io/component: operator
        control-plane: storageos-operator
    spec:
      containers:
      - args:
        - --config=operator_config.yaml
        command:
        - /manager
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        envFrom:
        - configMapRef:
            name: storageos-related-images
        image: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/operator:v2.5.0-beta.1
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8081
          initialDelaySeconds: 15
          periodSeconds: 20
        name: manager
        readinessProbe:
          httpGet:
            path: /readyz
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 10
        securityContext:
          allowPrivilegeEscalation: false
        volumeMounts:
        - mountPath: /operator_config.yaml
          name: storageos-operator
          subPath: operator_config.yaml
      - args:
        - --secure-listen-address=0.0.0.0:8443
        - --upstream=http://127.0.0.1:8080/
        - --logtostderr=true
        - --v=10
        image: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/kube-rbac-proxy:v0.10.0
        name: kube-rbac-proxy
        ports:
        - containerPort: 8443
          name: https
      securityContext:
        runAsUser: 65532
      serviceAccountName: storageos-operator
      terminationGracePeriodSeconds: 10
      volumes:
      - configMap:
          name: storageos-operator
        name: storageos-operator
```

### ondat-cluster.yaml
The last file is related to the deployment of the Ondat cluster. Two sections can be updated:

- the ```Secret``` with a different one than the default one being user: storageos / pass: storageos
- the ```images``` section to match your custom registry

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
    csiNodeDriverRegistrarContainer: us-central1-docker.pkg.dev/shaped-complex-318513/ondat/csi-node-driver-registrar:v2.1.0
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

## start the installation process
Using the [Ondat storageos kubectl plugin](https://docs.ondat.io/v2.5/docs/install/kubernetes/#install-the-storageos-kubectl-plugin), the installation can proceed with the following command: 

```
kubectl storageos install --include-etcd --etcd-namespace storageos --stos-cluster-yaml ondat-cluster.yaml --stos-version v2.5.0-beta.1 --stos-cluster-namespace storageos --stos-operator-yaml ondat-operator.yaml --etcd-cluster-yaml ondat-etcd-cluster.yaml --etcd-operator-yaml ondat-etcd-operator.yaml --skip-etcd-endpoints-validation
```

leading the following output:
```
namespace/ondat configured
namespace/ondat configured
namespace/ondat configured
customresourcedefinition.apiextensions.k8s.io/storageosclusters.storageos.com created
serviceaccount/storageos-operator created
clusterrole.rbac.authorization.k8s.io/storageos:metrics-reader created
clusterrole.rbac.authorization.k8s.io/storageos:operator created
clusterrole.rbac.authorization.k8s.io/storageos:operator:api-manager created
clusterrole.rbac.authorization.k8s.io/storageos:operator:scheduler-extender created
clusterrole.rbac.authorization.k8s.io/storageos:proxy created
customresourcedefinition.apiextensions.k8s.io/etcdbackups.etcd.improbable.io created
clusterrolebinding.rbac.authorization.k8s.io/storageos:operator created
customresourcedefinition.apiextensions.k8s.io/etcdbackupschedules.etcd.improbable.io created
clusterrolebinding.rbac.authorization.k8s.io/storageos:operator:api-manager created
clusterrolebinding.rbac.authorization.k8s.io/storageos:operator:scheduler-extender created
customresourcedefinition.apiextensions.k8s.io/etcdclusters.etcd.improbable.io created
clusterrolebinding.rbac.authorization.k8s.io/storageos:proxy created
customresourcedefinition.apiextensions.k8s.io/etcdpeers.etcd.improbable.io created
customresourcedefinition.apiextensions.k8s.io/etcdrestores.etcd.improbable.io created
configmap/storageos-operator created
role.rbac.authorization.k8s.io/storageos-etcd-leader-election-role created
configmap/storageos-related-images created
clusterrole.rbac.authorization.k8s.io/storageos-etcd-manager-role created
service/storageos-operator created
rolebinding.rbac.authorization.k8s.io/storageos-etcd-leader-election-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/storageos-etcd-manager-rolebinding created
service/storageos-operator-webhook created
service/storageos-etcd-proxy created
deployment.apps/storageos-operator created
deployment.apps/storageos-etcd-controller-manager created
validatingwebhookconfiguration.admissionregistration.k8s.io/storageos-operator-validating-webhook created
deployment.apps/storageos-etcd-proxy created
etcdcluster.etcd.improbable.io/storageos-etcd created
resourcequota/storageos-critical-pods created
secret/storageos-api created
storageoscluster.storageos.com/storageos-cluster created
```
