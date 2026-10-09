# Cluster Architecture, Installation and Configuration

## Focus Areas (25% of Exam)

### 1. Role Based Access Control (RBAC)
- Managing ServiceAccounts, Roles, and RoleBindings.
- Managing ClusterRoles and ClusterRoleBindings.
- Verifying permissions with `kubectl auth can-i`.

### 2. Kubeadm
- Initializing a cluster using `kubeadm init`.
- Joining nodes using `kubeadm join`.
- Renewing certificates using `kubeadm certs renew`.

### 3. Upgrading a Cluster
- Upgrading kubeadm on master and worker nodes.
- Upgrading the control plane components.
- Draining and uncordoning nodes (`kubectl drain`, `kubectl uncordon`).
- Upgrading kubelet and kubectl.

### 4. Backup and Restore etcd
- Knowing how to use `etcdctl` to take snapshots.
- Restoring an etcd snapshot.
- Understanding etcd endpoints, certificates, and keys.

### Practice Exercises to Master:
- Create a user and grant them read-only access to a specific namespace.
- Safely upgrade a multi-node cluster from one minor version to the next.
- Backup the etcd database and perform a complete restore.

---

## Practice Checklist (exercises already in this repo)

- [ ] [04-rbac](../../exercises/04-rbac)
- [ ] [09-kubeadm-upgrade](../../exercises/09-kubeadm-upgrade)
- [ ] [08-node-drain-cordon](../../exercises/08-node-drain-cordon)
- [ ] [39-etcd-version-snapshot](../../exercises/39-etcd-version-snapshot)
- [ ] [10-static-pod](../../exercises/10-static-pod)
- [ ] [35-kubelet-tls-bootstrapping](../../exercises/35-kubelet-tls-bootstrapping)
- [ ] [40-controlplane-components-report](../../exercises/40-controlplane-components-report)
- [ ] [13-helm-install-upgrade](../../exercises/13-helm-install-upgrade)
- [ ] [14-kustomize-overlays](../../exercises/14-kustomize-overlays)
- [ ] [27-cni-tigera-install](../../exercises/27-cni-tigera-install)
- [ ] [18-cri-dockerd-setup](../../exercises/18-cri-dockerd-setup)
- [ ] [49-kustomize-operator-rbac](../../exercises/49-kustomize-operator-rbac)
- [ ] killer.sh: [certificate_management.md](../../killer_sh_exam_1/certificate_management.md)

## Must-Know Commands

```bash
kubectl auth can-i list pods --as=system:serviceaccount:<ns>:<sa> -n <ns>
kubeadm certs check-expiration
kubeadm upgrade plan && kubeadm upgrade apply v1.X.Y   # control plane
kubeadm upgrade node                                   # workers
ETCDCTL_API=3 etcdctl snapshot save /tmp/snap.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```
