# Exercise 38 — Troubleshoot Dead Kubelet Service

> Related: [README — Troubleshooting](../../README.md#domain-7--troubleshooting-30) | **Updated May 2026**

Identify and resolve a stopped or misconfigured Kubelet systemd service on a control plane node.

## Tasks

1. Troubleshoot Kubelet on controlplane node.
2. Fix the Kubelet service so the node reports `Ready` status.
3. Create a Pod called `success` in `default` Namespace of image `nginx:1-alpine`.

<details>
<summary>Solution</summary>

```bash
# 1. Check systemd status
sudo systemctl status kubelet

# 2. Start and enable kubelet service
sudo systemctl enable --now kubelet

# 3. Verify node is Ready
kubectl get nodes

# 4. Create success pod
kubectl run success --image=nginx:1-alpine
```

</details>
