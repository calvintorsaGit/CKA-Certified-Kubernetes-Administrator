# Exercise 40 — Controlplane Components Architecture Report

> Related: [README — Cluster Architecture](../../README.md#domain-1--cluster-architecture-25) | **Updated May 2026**

Audit node process runtime types (process vs static-pod vs pod) for all Kubernetes control plane components and DNS addon.

## Tasks

Find how components are installed/started on the controlplane node:
- `kubelet`
- `kube-apiserver`
- `kube-scheduler`
- `kube-controller-manager`
- `etcd`
- `dns`

Write output to `/course/8/controlplane-components.txt` structured as:
```text
kubelet: [TYPE]
kube-apiserver: [TYPE]
kube-scheduler: [TYPE]
kube-controller-manager: [TYPE]
etcd: [TYPE]
dns: [TYPE] [NAME]
```
*(Types: `not-installed`, `process`, `static-pod`, `pod`)*

<details>
<summary>Solution</summary>

```bash
mkdir -p /course/8

cat <<EOF > /course/8/controlplane-components.txt
kubelet: process
kube-apiserver: static-pod
kube-scheduler: static-pod
kube-controller-manager: static-pod
etcd: static-pod
dns: pod coredns
EOF
```

</details>
