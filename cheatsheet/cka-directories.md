# CKA Exam — Critical Directories Cheatsheet

> All the Linux filesystem paths you must know for the Certified Kubernetes Administrator exam.

---

## 🏗️ Control Plane & Static Pods

| Directory                    | Purpose                                                                                  |
| ------------------------------| ------------------------------------------------------------------------------------------|
| `/etc/kubernetes/`           | Main Kubernetes config directory                                                         |
| `/etc/kubernetes/manifests/` | **Static pod manifests** — kube-apiserver, etcd, kube-scheduler, kube-controller-manager |
| `/etc/kubernetes/pki/`       | Cluster TLS certificates (CA, apiserver certs)                                           |
| `/etc/kubernetes/pki/etcd/`  | etcd-specific certs: `ca.crt`, `server.crt`, `server.key`                                |
| `/etc/kubernetes/admin.conf` | Admin kubeconfig file (copy to `~/.kube/config` after `kubeadm init`)                    |

### Static Pod Manifests — What's Inside `/etc/kubernetes/manifests/`

```
/etc/kubernetes/manifests/
├── etcd.yaml
├── kube-apiserver.yaml
├── kube-controller-manager.yaml
└── kube-scheduler.yaml
```

> **⚠️ IMPORTANT:** Editing a YAML file in this directory **auto-restarts** the corresponding static pod. A typo here can take down the entire cluster.

---

## 🔐 PKI / Certificates — `/etc/kubernetes/pki/`

```
/etc/kubernetes/pki/
├── ca.crt                  # Cluster CA certificate
├── ca.key                  # Cluster CA key
├── apiserver.crt           # API server certificate
├── apiserver.key           # API server key
├── apiserver-kubelet-client.crt
├── apiserver-kubelet-client.key
├── front-proxy-ca.crt
├── front-proxy-client.crt
├── sa.key                  # Service account signing key
├── sa.pub                  # Service account public key
└── etcd/
    ├── ca.crt              # etcd CA
    ├── server.crt          # etcd server cert
    ├── server.key          # etcd server key
    ├── peer.crt
    └── healthcheck-client.crt
```

---

## ⚙️ Kubelet

| Directory / File                                  | Purpose                                                              |
| ---------------------------------------------------| ----------------------------------------------------------------------|
| `/var/lib/kubelet/`                               | Kubelet working directory                                            |
| `/var/lib/kubelet/config.yaml`                    | Kubelet configuration (contains `staticPodPath`, `clusterDNS`, etc.) |
| `/var/lib/kubelet/pki/`                           | Kubelet TLS certificates                                             |
| `/var/lib/kubelet/pki/kubelet-client-current.pem` | Client cert (kubelet → apiserver)                                    |
| `/var/lib/kubelet/pki/kubelet-server-current.pem` | Server cert (apiserver → kubelet)                                    |
| `/etc/systemd/system/kubelet.service.d/`          | Kubelet systemd drop-in configuration                                |

### Finding the Static Pod Path (if non-default)

```bash
cat /var/lib/kubelet/config.yaml | grep staticPodPath
```

> **⚠️ WARNING:** Kubelet is a **systemd service**, NOT a static pod. Use `systemctl` and `journalctl` — not `kubectl logs`.

```bash
systemctl status kubelet
systemctl restart kubelet
journalctl -u kubelet -f
```

---

## 💾 etcd

| Directory / File | Purpose |
|---|---|
| `/var/lib/etcd/` | etcd data directory |

### etcd Backup & Restore Commands

```bash
# Find cert paths from the etcd manifest
cat /etc/kubernetes/manifests/etcd.yaml | grep -E "cert-file|key-file|trusted-ca"

# Snapshot
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Restore
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
  --data-dir=/var/lib/etcd-restored
```

> **💡 TIP:** After restore, update `--data-dir` in `/etc/kubernetes/manifests/etcd.yaml` to point to the new directory.

---

## 🌐 Container Runtime & CNI

| Directory                     | Purpose                          |
| -------------------------------| ----------------------------------|
| `/etc/cni/net.d/`             | CNI plugin configuration files   |
| `/opt/cni/bin/`               | CNI plugin binaries              |
| `/etc/containerd/config.toml` | containerd runtime configuration |

---

## 👤 Kubectl & User Config

| Directory / File | Purpose |
|---|---|
| `~/.kube/config` | Default kubeconfig for `kubectl` |
| `$KUBECONFIG` | Environment variable to override kubeconfig location |

```bash
# Copy admin config after kubeadm init
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 📋 Logs (When `kubectl` Is Broken)

| Directory | Purpose |
|---|---|
| `/var/log/pods/` | Pod logs on the node |
| `/var/log/containers/` | Container log symlinks |
| `/var/log/syslog` or `journalctl` | System-level logs |

```bash
# When kubectl is completely down, use crictl
crictl ps
crictl pods
crictl logs <container-id>
```

---

## ⚠️ Top Exam Traps

1. **`/etc/kubernetes/manifests/`** — Edit = auto-restart. Typo = cluster down. Always double-check YAML before saving.
2. **etcd cert paths** — Don't guess! Read them from `cat /etc/kubernetes/manifests/etcd.yaml`.
3. **Kubelet ≠ static pod** — It's a systemd service. `systemctl restart kubelet`, not `kubectl delete pod`.
4. **Client cert vs. Server cert** — `kubelet-client-current.pem` (outgoing to apiserver) vs. `kubelet-server-current.pem` (incoming from apiserver).
5. **`staticPodPath`** — Not always `/etc/kubernetes/manifests/`. Check `/var/lib/kubelet/config.yaml` to be sure.
6. **etcd restore `--data-dir`** — Must point to a **new** directory, then update `etcd.yaml` manifest to match.
