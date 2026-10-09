# Troubleshooting

## Focus Areas (30% of Exam)

### 1. Cluster Component Troubleshooting
- Diagnosing issues with `kube-apiserver`, `kube-controller-manager`, and `kube-scheduler`.
- Using `journalctl -u kubelet` to find why a node is NotReady.
- Checking static pod manifests in `/etc/kubernetes/manifests/`.

### 2. Application Troubleshooting
- Using `kubectl describe pod` to find scheduling issues, ImagePullBackOff, or OOMKilled.
- Checking logs with `kubectl logs`.
- Debugging crashing pods.

### 3. Networking Troubleshooting
- Verifying DNS resolution (CoreDNS).
- Troubleshooting Service endpoints (`kubectl get endpoints`).
- Using `busybox` or `netshoot` to trace connectivity.

### 4. Node Troubleshooting
- Dealing with resource starvation on nodes.
- Recovering a failed worker node.

### Practice Exercises to Master:
- Given a broken worker node, find the issue (e.g., stopped kubelet) and fix it.
- Fix a broken static pod (e.g., a typo in `/etc/kubernetes/manifests/kube-apiserver.yaml`).
- Debug why a Service is not forwarding traffic to its backend Pods.

---

## Practice Checklist (exercises already in this repo)

- [ ] [11-troubleshoot-cluster](../../exercises/11-troubleshoot-cluster)
- [ ] [38-fix-dead-kubelet](../../exercises/38-fix-dead-kubelet)
- [ ] [29-troubleshoot-etcd-endpoint](../../exercises/29-troubleshoot-etcd-endpoint)
- [ ] [17-kubectl-debug](../../exercises/17-kubectl-debug)
- [ ] [36-readiness-probe-dependency](../../exercises/36-readiness-probe-dependency)
- [ ] [47-cluster-events-logging](../../exercises/47-cluster-events-logging)
- [ ] [37-kubectl-sorting-scripts](../../exercises/37-kubectl-sorting-scripts)
- [ ] [48-api-resources-crowded-namespace](../../exercises/48-api-resources-crowded-namespace)

**Reference:** [troubleshooting/README.md](../../troubleshooting/README.md), [DIAGNOSTICS.md](../../DIAGNOSTICS.md)

## Quick Debug Flow

```bash
kubectl get nodes                               # NotReady?
ssh <node>; systemctl status kubelet            # kubelet running?
journalctl -u kubelet --no-pager | tail -50     # why not?
crictl ps -a | grep -E 'apiserver|etcd|sched|controller'   # control plane up?
crictl logs <container-id>                      # control plane error
cat /etc/kubernetes/manifests/kube-apiserver.yaml          # typos / wrong paths
kubectl get events -A --sort-by=.lastTimestamp  # cluster events
kubectl get endpoints <svc>                     # empty = selector mismatch
```
