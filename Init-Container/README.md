
# LIO install for older releases

For the up to date list of Linux versions supported by Ondat please see the official documentaion [prerequisites page](https://docs.ondat.io/docs/prerequisites)

Ondat uses native Linux components which can be either:
* compiled into the linux kernel
* supplied as pre-compiled modules which can be loaded dynamically as required on demand
* compiled as modules but only shipped as part of additional module packages

With recent releases of popular distributions such as Ubuntu 22.04 these modules are included in the base distribution and will be loaded automatically for Ondat to work. For example you can look at the `/boot/config-<kernel-version>` files and you will see that the target core components are modules which can be dynamically loaded, e.g.

```bash
$ cat /boot/config-5.4.0-120-generic |grep -i tcm
CONFIG_TCM_QLA2XXX=m
# CONFIG_TCM_QLA2XXX_DEBUG is not set
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
CONFIG_TCM_USER2=m
CONFIG_TCM_FC=m
CONFIG_USB_F_TCM=m
CONFIG_USB_CONFIGFS_F_TCM=y

$ lsmod |grep -i tcm
tcm_loop               28672  9
target_core_mod       360448  18 tcm_loop,target_core_file,target_core_iblock,target_core_pscsi,target_core_user
```

# Older releases, for example Ubuntu 18.04
For older releases of Ubuntu such as 18.04, we have a script which is referenced in the documentation pages above which can install these modules onto a machine. To save time in having to run this script on every machine in a cluster, we developed a prototype daemon set to run this on every node using kubernetes.

> **WARNING**: While the following has been tested and used on a test environment, it is not something that is part of the offical product and is supplied under the Apache2 license, so the below is supplied "AS IS" BASIS, WITHOUT  WARRANTIES OR CONDITIONS OF ANY KIND.

### Kubernetes Definitions

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: storageos

# ServiceAccount for modinstall-DaemonSet
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: modinstall-daemonset-sa 
  namespace: storageos

# ClusterRole for init container.
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: init-container
rules:
- apiGroups:
  - apps
  resources:
  - daemonsets
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - create
  - get
  - list
  - delete


# Bind DaemonSet ServiceAccount with init-container ClusterRole.
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: init-container
subjects:
- kind: ServiceAccount
  name: modinstall-daemonset-sa
  namespace: storageos
roleRef:
  kind: ClusterRole
  name: init-container
  apiGroup: rbac.authorization.k8s.io

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: modinstall-daemonset
  namespace: storageos
  labels:
    app: modinstall-daemonset
spec:
  selector:
    matchLabels:
      name: modinstall-daemonset
  template:
    metadata:
      labels:
        name: modinstall-daemonset
    spec:
      serviceAccountName: modinstall-daemonset-sa
      initContainers:
      - name: modinstall
        image: storageos/modinstall:ubuntu1804.1
        env:
          - name: MOD_INSTALL
            value: INSTALL
        command: [ 'bash']
        args: [ 'scripts/01-lio/enable-lio.sh' ]
        volumeMounts:
          - name: kernel-modules
            mountPath: /lib/modules
            mountPropagation: Bidirectional
          - name: sys
            mountPath: /sys
            mountPropagation: Bidirectional
        securityContext:
          privileged: true
          capabilities:
            add:
            - SYS_ADMIN
      containers:
      - name: wait
        image: storageos/modinstall:ubuntu1804.1
        command: [ 'sleep']
        args: [ 'infinity' ]
      volumes:
        - name: kernel-modules
          hostPath:
            path: /lib/modules
        - name: sys
          hostPath:
            path: /sys
  updateStrategy:
    type: OnDelete

```
