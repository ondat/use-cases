# Testing storage performance as a pod 

This script wraps an fio container, a lot of PVC's, a config map and has hooks to drop fs cache if needed.

### Kubernetes definitions

Please find below the PVC and Job definitions.

```YAML
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-1
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-2
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-3
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-4
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-5
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-6
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-7
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: claim-8
spec:
  storageClassName: storageos
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Ti
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: fio-config
data: 
  workload.fio: |
    [global]           
    bs=4k          
    ioengine=libaio    
    iodepth=128      
    thread=1           
    direct=1           
    rw=randwrite        
    group_reporting=0  
    time_based=1       
    runtime=120        
                      
    [local1]           
    numjobs=1          
    filename=/data1/blob
    size=100G

    [local2]           
    numjobs=1          
    filename=/data2/blob
    size=100G

    [local3]           
    numjobs=1          
    filename=/data3/blob
    size=100G

    [local4]           
    numjobs=1          
    filename=/data4/blob
    size=100G

    [local5]           
    numjobs=1          
    filename=/data5/blob
    size=100G

    [local6]           
    numjobs=1          
    filename=/data6/blob
    size=100G

    [local7]           
    numjobs=1          
    filename=/data7/blob
    size=100G

    [local8]           
    numjobs=1          
    filename=/data8/blob
    size=100G
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
          - "/usr/bin/fio"
          - "--output-format=normal"
          - "--minimal"
          - "/etc/fio/workload.fio"
        env:
        - name: FIO_fdatasync
          value: "0"
        volumeMounts:
        - name: volume-1
          mountPath: /data1
        - name: volume-2
          mountPath: /data2
        - name: volume-3
          mountPath: /data3
        - name: volume-4
          mountPath: /data4
        - name: volume-5
          mountPath: /data5
        - name: volume-6
          mountPath: /data6
        - name: volume-7
          mountPath: /data7
        - name: volume-8
          mountPath: /data8
        - name: proc1
          mountPath: /proc
          mountPropagation: Bidirectional
        - name: fio-config-volume
          mountPath: /etc/fio
      restartPolicy: Never
      volumes:
      - name: volume-1
        persistentVolumeClaim:
          claimName: claim-1
      - name: volume-2
        persistentVolumeClaim:
          claimName: claim-2
      - name: volume-3
        persistentVolumeClaim:
          claimName: claim-3
      - name: volume-4
        persistentVolumeClaim:
          claimName: claim-4
      - name: volume-5
        persistentVolumeClaim:
          claimName: claim-5
      - name: volume-6
        persistentVolumeClaim:
          claimName: claim-6
      - name: volume-7
        persistentVolumeClaim:
          claimName: claim-7
      - name: volume-8
        persistentVolumeClaim:
          claimName: claim-8
      - name: proc1
        hostPath:
          path: /proc
      - name: fio-config-volume
        configMap:
          name: fio-config
```

## To parse the output

This has been set to output with --minimal. You can parse the output with:

```bash
kubectl logs job/fio -f | awk -F';' 'BEGIN {printf "%30s %8s %9s %8s   %8s %9s %8s\n", "Test file", "R iops", "R lat ms", "R MB/s", "W iops", "W lat ms", "W MB/s"} {records +=1} {readsum += $8} {writesum += $49} {readmb += $7} {writemb += $48} {readlats += $40 } {writelats += $81} {printf "%30s '$YELLOW'%8d'$NC' '$GREEN'%9.3f'$NC' %8.1f   '$YELLOW'%8d'$NC' '$GREEN'%9.3f'$NC' %8.1f  \n", $3, $8, $40/1000, $7/1024, $49, $81/1000, $48/1024} END {printf "'$CYAN'%30s %8d %9.3f %8.1f   %8d %9.3f %8.1f'$NC'\n\n", "TOTAL/Average", readsum, (readlats/records)/1000, readmb/1024, writesum, (writelats/records)/1000, writemb/1024}'
```
