#!/bin/bash

set -e

ETCD_STORAGECLASS=""
STOS_NS=storageos
ETCD_NS=storageos-etcd

while getopts s:e: opt; do
    case $opt in
        s) ETCD_STORAGECLASS=$OPTARG ;;
        e) ETCD_ENDPOINT=$OPTARG ;;
    esac
done

if [ -z $ETCD_STORAGECLASS ] || [ -z $ETCD_ENDPOINT ]; then
	echo "Missing arguments" >&2
	echo "$0 -s ETCD_STORAGECLASS -e ETCD_ENDPOINT" >&2
	exit 1
fi


function backup_secret {
    local secret_name="$1"
    kubectl -n $STOS_NS get secret $secret_name -oyaml > /tmp/${secret_name}.yaml
    echo "Storing a backup of the storageos-etcd-secret in /tmp/${secret_name}.yaml"
}

### Main ###

# Backup TLS secret
SECRET=""
if kubectl -n $STOS_NS get secret storageos-etcd-secret &> /dev/null; then
    SECRET=storageos-etcd-secret
    backup_secret $SECRET
elif kubectl -n $STOS_NS get secret etcd-client-tls &> /dev/null; then
    SECRET=etcd-client-tls
    backup_secret $SECRET
else
    echo "The secrets storageos-etcd-secret or etcd-client-tls couldn't be found in the $STOS_NS namespace."
    exit 1
fi

# Deploy etcd in k8s
if ! command -v helm &> /dev/null; then
    echo "Helm cannot be found, it is a requirement of the migration. Please install helm."
    exit 1
fi

NEW_TLS_SECRET=storageos-etcd-secret-incluster 
helm repo add ondat https://ondat.github.io/charts &> /dev/null
helm upgrade --install storageos-etcd ondat/etcd-cluster-operator \
    --create-namespace \
    --namespace etcd-operator \
    --set ondat.secret=$NEW_TLS_SECRET \
    --set cluster.storageclass=$ETCD_STORAGECLASS

# Wait for etcd to be ready
TIMEOUT=120
time=0
echo "Wating for etcd to be ready"
while ! kubectl -n $ETCD_NS get pod 2>/dev/null | grep -q "1/1"; do
	if [ $time -gt $TIMEOUT ]; then
        echo 
		echo "Waited for etcd to become ready for $TIMEOUT seconds, aborting!"
		echo "Check that the StorageClass for etcd: \"$ETCD_STORAGECLASS\" exists and make sure that pods are schedulable"
		echo "It is recommended to uninstall etcd once the issue is troubleshooted:"
		echo -e "\t helm uninstall storageos-etcd -n etcd-operator"
		echo -e "\t kubectl -n $STOS_NS delete secret $NEW_TLS_SECRET"
		exit 1
    fi

	echo -n "."
	sleep 1
	((time=time+1))
done

echo
echo "Etcd is ready"


# Mirror etcd clusters
kubectl -n $STOS_NS create -f-<<END
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: etcdctl
  name: etcdctl-migration
spec:
  containers:
  - image: quay.io/coreos/etcd:v3.5.3
    name: etcdctl
    env:
    - name: OLD_ETCD_ENDPOINT
      value: $ETCD_ENDPOINT
    - name: NEW_ETCD_ENDPOINT
      value: https://storageos-etcd.$ETCD_NS:2379
    - name: OLD_ETCD_CERTS_DIR
      value: '/etc/etcd_old/certs' # defined in the volumes from a Secret
    - name: NEW_ETCD_CERTS_DIR
      value: '/etc/etcd_new/certs' # defined in the volumes from a Secret
    - name: OLD_ETCD_CMD_OPTS
      value: "--endpoints \$(OLD_ETCD_ENDPOINT) --cacert \$(OLD_ETCD_CERTS_DIR)/etcd-client-ca.crt --key \$(OLD_ETCD_CERTS_DIR)/etcd-client.key --cert \$(OLD_ETCD_CERTS_DIR)/etcd-client.crt"
    - name: NEW_ETCD_CMD_OPTS
      value: "--endpoints \$(NEW_ETCD_ENDPOINT) --cacert \$(NEW_ETCD_CERTS_DIR)/etcd-client-ca.crt --key \$(NEW_ETCD_CERTS_DIR)/etcd-client.key --cert \$(NEW_ETCD_CERTS_DIR)/etcd-client.crt"
    command: [ "/bin/sh", "-c" ]
    args:
    - "
        etcdctl make-mirror \
        \$(OLD_ETCD_CMD_OPTS) \
        --dest-cacert \$(NEW_ETCD_CERTS_DIR)/etcd-client-ca.crt \
        --dest-cert \$(NEW_ETCD_CERTS_DIR)/etcd-client.crt \
        --dest-key \$(NEW_ETCD_CERTS_DIR)/etcd-client.key \
        \$(NEW_ETCD_ENDPOINT)
        "
    volumeMounts:
    - mountPath: /etc/etcd_old/certs
      name: cert-dir-old
    - mountPath: /etc/etcd_new/certs
      name: cert-dir-new
  volumes:
  - name: cert-dir-old
    secret:
      defaultMode: 420
      secretName: $SECRET
  - name: cert-dir-new
    secret:
      defaultMode: 420
      secretName: $NEW_TLS_SECRET 
END


# Wait for the mirror
TIMEOUT=120
time=0
echo "Wating for the mirror"
while ! kubectl -n $STOS_NS logs etcdctl-migration 2>/dev/null | grep -q "[0-9]\{2\}"; do
	if [ $time -gt $TIMEOUT ]; then
        echo 
		echo "Waited for the mirror for $TIMEOUT seconds, aborting!"
		echo "Exec into the etcdctl-migration and troubleshoot the issue. "
        echo -e "\tkubectl -n $STOS_NS exec -it etcdctl-migration -- bash"
        echo "Check for:"
        echo -e "\t- If the env vars are loaded correctly: env | grep ETCD"
        echo -e "\t- If you can connect to both etcd clusters:"
        echo -e "\t\t etcdctl \$OLD_ETCD_CMD_OPTS member list"
        echo -e "\t\t etcdctl \$NEW_ETCD_CMD_OPTS member list"
		echo "Once the issue is troubleshooted, it is recommended to delete the etcdctl-migration pod to rerun the migration script"
        echo -e "\tkubectl -n $STOS_NS delete pod etcdctl-migration --wait=false"
		exit 1
    fi

	echo -n "."
	sleep 1
	((time=time+1))
done

echo 
echo "Mirror between etcds is running successfully"

# Backup StorageOSCluster resource
echo "Backing up the StorageOSCluster configuration"
kubectl get storageosclusters.storageos.com \
    -n $STOS_NS \
    -o yaml \
    storageoscluster > /tmp/storageos-cluster.yaml


sed -i.bak -e "s/address: .*/address: storageos-etcd.$ETCD_NS:2379/g" /tmp/storageos-cluster.yaml
sed -i.bak -e "s/tlsEtcdSecretRefName: .*/tlsEtcdSecretRefName: $NEW_TLS_SECRET/g" /tmp/storageos-cluster.yaml

# Restarting ondat
echo "Stopping Ondat"
kubectl -n $STOS_NS delete -f /tmp/storageos-cluster.yaml
sleep 10

# Echo stopping mirror
echo "Stopping etcd mirror"
kubectl -n $STOS_NS delete pod etcdctl-migration --wait=false

echo "Starting Ondat"
kubectl -n $STOS_NS create -f /tmp/storageos-cluster.yaml
sleep 10

# Wait for Ondat to be ready
TIMEOUT=60
time=0
echo "Wating for Ondat to be ready"
while kubectl -n $STOS_NS get ds storageos-node -oyaml -ojsonpath='{.status.numberReady}' | grep -q "0"; do
	if [ $time -gt $TIMEOUT ]; then
        echo 
		echo "Waited for Ondat to become ready for $TIMEOUT seconds, aborting!"
        kubectl -n $STOS_NS get pods
		echo "Check that Ondat can connect to the new etcd"
        echo -e "\t kubectl -n $STOS_NS logs ds/storageos-node"
		exit 1
    fi

	echo -n "."
	sleep 1
	((time=time+1))
done

echo
echo "Ondat is ready"

# Checking that Ondat is pointing to the new etcd
echo "Checking that Ondat is pointing to the new etcd cluster in the node container logs:"
if kubectl -n $STOS_NS logs ds/storageos-node 2>/dev/null| grep "storageos-etcd.$ETCD_NS:2379" | grep -q "ETCD connection established at"; then
    echo -e "\tsuccess!"
fi
