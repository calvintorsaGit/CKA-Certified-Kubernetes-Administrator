# Exercise 46 — Cluster Architecture & CNI Audit Report

> Related: [README — Services & Networking](../../README.md#domain-4--services--networking-20) | **Updated May 2026**

Extract node topology, Service CIDR, CNI plugin configuration files, and static pod naming conventions.

## Tasks

Write findings to `/course/14/cluster-info` formatted as:
```text
1: [Controlplane count]
2: [Worker count]
3: [Service CIDR]
4: [CNI Plugin & config file path]
5: [Static pod suffix]
```

<details>
<summary>Solution</summary>

```bash
mkdir -p /course/14

CP_COUNT=$(kubectl get nodes --selector=node-role.kubernetes.io/control-plane --no-headers | wc -l)
WORKER_COUNT=$(kubectl get nodes --selector='!node-role.kubernetes.io/control-plane' --no-headers | wc -l)
SVC_CIDR=$(grep -- "--service-cluster-ip-range" /etc/kubernetes/manifests/kube-apiserver.yaml | cut -d= -f2)
CNI_INFO=$(ls /etc/cni/net.d/ | head -n 1)

cat <<EOF > /course/14/cluster-info
1: ${CP_COUNT}
2: ${WORKER_COUNT}
3: ${SVC_CIDR}
4: ${CNI_INFO} /etc/cni/net.d/${CNI_INFO}
5: -$(hostname)
EOF
```

</details>
