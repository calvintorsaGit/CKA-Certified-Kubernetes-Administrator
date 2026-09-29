# Exercise 39 — etcd Version & Snapshot Save

> Related: [README — Cluster Architecture](../../README.md#domain-1--cluster-architecture-25) | **Updated May 2026**

Retrieve etcd binary version details and execute a secure TLS snapshot backup using `etcdctl`.

## Tasks

1. Run `etcd --version` / `etcdctl version` and store the output at `/course/7/etcd-version`.
2. Save an etcd snapshot at `/course/7/etcd-snapshot.db`.

<details>
<summary>Solution</summary>

```bash
mkdir -p /course/7

# 1. Version output
ETCDCTL_API=3 etcdctl version > /course/7/etcd-version

# 2. Backup snapshot with TLS flags
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /course/7/etcd-snapshot.db
```

</details>
