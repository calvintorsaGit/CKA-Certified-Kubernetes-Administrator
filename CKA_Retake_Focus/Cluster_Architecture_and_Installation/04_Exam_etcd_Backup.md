# Exam 04: ETCD Backup and Restore

**Domain:** Cluster Architecture, Installation & Configuration (25%)

## Context
> *You have been asked to take a snapshot of the etcd datastore before the team performs a major cluster upgrade.*

## Your Task
1. Take a snapshot of the etcd database and save it to `/opt/backup/etcd-snapshot.db` on the control plane node.
2. The etcd runs on `https://127.0.0.1:2379`.
3. Use the certificates located at `/etc/kubernetes/pki/etcd/` to authenticate.

---

## 🛠️ Playground Setup
No setup required, but you must run this on the control plane node of a real cluster (like killercoda), as it requires access to the etcd certificates. Ensure the directory exists:
```bash
mkdir -p /opt/backup
```
<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Find the certificate paths
If you don't know the paths, you can check the etcd static pod manifest:
```bash
cat /etc/kubernetes/manifests/etcd.yaml | grep file
```

### Step 2: Take the Snapshot
Use `etcdctl` with `ETCDCTL_API=3` to take the snapshot. You must provide the endpoint, CA cert, client cert, and client key:
```bash
ETCDCTL_API=3 etcdctl snapshot save /opt/backup/etcd-snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

### Step 3: Verify the Snapshot
```bash
ETCDCTL_API=3 etcdctl snapshot status /opt/backup/etcd-snapshot.db
```
