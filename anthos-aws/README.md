# How to install Ondat on a Google Anthos deployed on AWS
**NOTE**: Although the following solution is fairly simple to implement, we advise you to engage with our Customer Success Team due to the specifics of such deployment from a k8s cluster standpoint.

Once a fully deployed and accessible Google Anthos k8s is deployed on AWS, Ondat can be installed using the ```kubectl storageos``` plugin. 

Reference: get the plugin [here](https://github.com/storageos/kubectl-storageos) or follow the ondat documentation [here](https://docs.ondat.io/v2.5/docs/install/kubernetes/#install-the-storageos-kubectl-plugin).

What is included in this folder:  
- ```ondat-etcd.yaml```: the configuration file for the Ondat etcd
- ```ondat-cluster.yaml```: the Ondat cluster configuration file 
- ```test-dep-rwo.yaml```: a read-write-once deployment test
- ```test-dep-rwx.yaml```: a read-write-many deployment test 

## installation
On the admin host from which the Google Anthos k8s on AWS is accessible, run the following: 

```shell
kubectl storageos install --include-etcd --etcd-cluster-yaml ondat-etcd.yaml --etcd-namespace storageos --stos-cluster-yaml ondat-cluster.yaml --stos-cluster-namespace storageos --stos-version v2.5.0-beta.1
```

Let's have a look at the parameters:
- ```--include-etcd```: deploy the Ondat etcd within the k8s cluster
- ```--etcd-cluster-yaml ondat-etcd.yaml```: overwrite the default plugin parameters with the one from the configuration file 
- ```--etcd-namespace storageos```: overwrite the default plugin parameters to deploy the etcd cluster within a custom namespace
- ```--stos-cluster-yaml ondat-cluster.yaml```: overwrite the default plugin parameters with the one from this configuration file
- ```--stos-cluster-namespace storageos```: overwrite the default plugin parameters to deploy the Ondat cluster within a custom namespace
- ```--stos-version v2.5.0-beta.1```: overwrite the default plugin parameters with the desired version

**NOTE**:  
- Do not change this two files, ```ondat-etcd.yaml``` and ```ondat-cluster.yaml```! This files have been tuned for the deployment of Ondat on google anthos k8s running on aws. 
- If customization is required, engage with the Ondat Customer Success Team.

Once the installation is done, the following outcome of ```kubectl get pod -n storageos```
 should be expected:

```
NAME                                                 READY   STATUS    RESTARTS   AGE
modinstall-daemonset-89ct7                           1/1     Running   0          3m10s
modinstall-daemonset-8x8bh                           1/1     Running   0          3m10s
modinstall-daemonset-zp6z6                           1/1     Running   0          3m10s
storageos-api-manager-85c7c7ff79-6qkw9               1/1     Running   0          2m20s
storageos-api-manager-85c7c7ff79-krfww               1/1     Running   0          2m20s
storageos-csi-helper-65dc8ff9d8-m5vm6                3/3     Running   0          2m20s
storageos-etcd-0-42qsc                               1/1     Running   0          3m47s
storageos-etcd-1-58r7j                               1/1     Running   0          3m47s
storageos-etcd-2-djrpx                               1/1     Running   0          3m47s
storageos-etcd-controller-manager-856cf69f69-pgg82   1/1     Running   0          4m7s
storageos-etcd-proxy-64cf4f6556-sbb86                1/1     Running   0          4m5s
storageos-node-6wxvd                                 3/3     Running   0          2m58s
storageos-node-9jgl6                                 3/3     Running   0          2m58s
storageos-node-g669g                                 3/3     Running   0          2m58s
storageos-operator-56bf9d4db7-wsscz                  2/2     Running   0          4m
storageos-scheduler-75dc6b5f56-swcm8                 1/1     Running   0          3m5s
```

## test with a RWO volume


## test with a RWX volume

