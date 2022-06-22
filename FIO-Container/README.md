# Testing storage performance as a pod 

Once you have configured Ondat on your kubernetes cluster, often you want to test the storage performance from the kubernetes point of view and get an idea of how your applications will perform. The following is an example wrapper to the [volume benchmark](https://github.com/chira001/volbench/blob/main/volbench.sh]) script and uses a kubernetes job to run this. It needs internet access to retrieve:
* A container image with FIO and Curl installed
* The script from github, although you could embed this as a config map for offline operations of course.

> **Note**: The script uses some variable which should be tuned for use case, please also note that you need to use a value > 4 for `FIO_size` in the script, so use 2048MB instead of 2GB. It also defaults to the storage class of `storageos` so please adjust this for the PVC as needed as well.

### Kubernetes definitions

Please find below the PVC and Job definitions.

```YAML
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: fio-pv-claim
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: batch/v1
kind: Job
metadata:
  name: fio
spec:
  template:
    spec:
      containers:
      - name: fio
        securityContext:
          privileged: true
          capabilities:
            add:
            - SYS_ADMIN
        image: quay.io/openshift-scale/etcd-perf:latest
        imagePullPolicy: Always
        command: 
          - sh
          - -c
          - curl https://raw.githubusercontent.com/chira001/volbench/main/volbench.sh | bash
        env:
        # specify a space seperated set of files to use as tests. tests are run in paralled across all files
        - name: FIO_files
          value: "/data/volbenchtest1"
        # specify the size of the test files
        - name: FIO_size
          value: "4GB"
        # specify a ramp time before recording values - this should be around 10 seconds
        - name: FIO_ramptime
          value: "1s"
        # specify a runtime for each test - should be 30s minimum, but 120 is preferred
        - name: FIO_runtime
          value: "120s"
        # specify the percentage of read requests in mixed tests
        - name: FIO_rwmixread
          value: "50"
        # specify how many write i/os before an fdatasync - 0 disables
        - name: FIO_fdatasync
          value: "0"
        volumeMounts:
        - name: fio-pv
          mountPath: /data
        - name: proc1
          mountPath: /proc
          mountPropagation: Bidirectional
      restartPolicy: Never
      volumes:
      - name: fio-pv
        persistentVolumeClaim:
          claimName: fio-pv-claim
      - name: proc1
        hostPath:
          path: /proc
#    - name: volbench-script
#        secret:
#        secretName: volbench
  backoffLimit: 4
```

### Sample Output

For a sample report file, please see the [sample](./sample-output.html) file located in this folder.