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

**NOTE**: Do not change this two files, ```ondat-etcd.yaml``` and ```ondat-cluster.yaml```! This files have been tuned for the deployment of Ondat on google anthos k8s running on aws. 

## test with a RWO volume


## test with a RWX volume

