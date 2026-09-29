# Exercise 41 — Manual Pod Scheduling Without Kube-Scheduler

> Related: [README — Workloads & Scheduling](../../README.md#domain-1--workloads--scheduling-15) | **Updated May 2026**

Simulate the Kubernetes scheduler by manually assigning pods to specific target nodes via `spec.nodeName` while `kube-scheduler` is offline.

## Tasks

1. Temporarily stop `kube-scheduler` in a way that lets you start it again afterwards.
2. Create a Pod named `manual-schedule` of image `httpd:2-alpine`, confirm it's created but not scheduled.
3. Manually schedule `manual-schedule` on node `cka5248`. Make sure it's running.
4. Start `kube-scheduler` again.
5. Create second Pod `manual-schedule2` of image `httpd:2-alpine` and confirm `kube-scheduler` automatically places it on node `cka5248-node1`.

<details>
<summary>Solution</summary>

```bash
# 1. Stop scheduler by moving static pod manifest out of watched directory
sudo mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/

# 2. Create unassigned pod
kubectl run manual-schedule --image=httpd:2-alpine

# 3. Assign node manually by binding nodeName
kubectl get pod manual-schedule -o yaml > pod.yaml
# Edit pod.yaml to add nodeName: cka5248 under spec
kubectl replace --force -f pod.yaml

# 4. Restart kube-scheduler
sudo mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/

# 5. Verify auto scheduling works
kubectl run manual-schedule2 --image=httpd:2-alpine
kubectl get pod manual-schedule2 -o wide
```

</details>
