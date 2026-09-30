# Exercise 42 — StorageClass WaitForFirstConsumer & Job PVC Integration

> Related: [README — Storage](../../README.md#domain-6--storage-10) | **Updated May 2026**

Create a custom StorageClass (`WaitForFirstConsumer`, `Retain`) and configure a Kubernetes Job manifest to claim dynamic persistent storage.

## Setup Environment

Run this script on your node to create the initial directory and broken Job manifest at `/course/10/backup.yaml`:

```bash
sudo mkdir -p /course/10

cat <<EOF | sudo tee /course/10/backup.yaml > /dev/null
apiVersion: batch/v1
kind: Job
metadata:
  name: backup-job
  namespace: default
spec:
  template:
    spec:
      containers:
      - name: backup
        image: busybox:1.36
        command: ["sh", "-c", "echo 'Backup completed at \$(date)' > /backup/data.txt"]
        volumeMounts:
        - name: backup-vol
          mountPath: /backup
      restartPolicy: Never
      volumes:
      - name: backup-vol
        persistentVolumeClaim:
          claimName: backup-pvc
EOF
```

## Tasks

1. Create a StorageClass named `local-backup` with:
   - `provisioner: rancher.io/local-path`
   - `volumeBindingMode: WaitForFirstConsumer`
   - `reclaimPolicy: Retain`
2. Adjust Job manifest at `/course/10/backup.yaml` to request a 50Mi PVC using StorageClass `local-backup`.
3. Deploy Job and verify PV is dynamically created and bound upon Pod execution.

<details>
<summary>Solution</summary>

```bash
# 1. Create StorageClass
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-backup
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain
EOF

# 2. Create PVC & update Job volume claim template inside /course/10/backup.yaml
# Ensure claimName: backup-pvc and requests: storage: 50Mi are set.
kubectl apply -f /course/10/backup.yaml
```

</details>
