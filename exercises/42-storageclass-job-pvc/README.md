# Exercise 42 — StorageClass WaitForFirstConsumer & Job PVC Integration

> Related: [README — Storage](../../README.md#domain-6--storage-10) | **Updated May 2026**

Create a custom StorageClass (`WaitForFirstConsumer`, `Retain`) and configure a Kubernetes Job manifest to claim dynamic persistent storage.

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
