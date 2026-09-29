# Exercise 47 — Cluster Event Monitoring & Lifecycle Auditing

> Related: [README — Troubleshooting](../../README.md#domain-7--troubleshooting-30) | **Updated May 2026**

Capture cluster-wide sorted events and log lifecycle events triggered by deleting pods and killing container runtime processes.

## Tasks

1. Write a `kubectl` command into `/course/15/cluster_events.sh` to display all cluster events sorted by `creationTimestamp`.
2. Delete `kube-proxy` Pod and write generated events into `/course/15/pod_kill.log`.
3. Kill containerd container of `kube-proxy` Pod and write events into `/course/15/container_kill.log`.

<details>
<summary>Solution</summary>

```bash
mkdir -p /course/15

# 1. Cluster events script
echo 'kubectl get events -A --sort-by=.metadata.creationTimestamp' > /course/15/cluster_events.sh
chmod +x /course/15/cluster_events.sh

# 2. Pod kill events
kubectl delete pod -n kube-system -l k8s-app=kube-proxy
kubectl get events -n kube-system --sort-by=.metadata.creationTimestamp > /course/15/pod_kill.log

# 3. Container kill events
CONTAINER_ID=$(sudo crictl ps --name kube-proxy -q | head -n 1)
sudo crictl stop $CONTAINER_ID
kubectl get events -n kube-system --sort-by=.metadata.creationTimestamp > /course/15/container_kill.log
```

</details>
