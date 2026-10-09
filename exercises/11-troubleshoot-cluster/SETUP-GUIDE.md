# Setup Guide: How to Break the Cluster

This exercise does not have an automated `setup.sh` script because breaking core cluster components (like `kubelet` or `kube-apiserver`) can be environment-specific and difficult to automatically revert.

To practice the scenarios in this exercise, follow these instructions to intentionally break your cluster.

## Scenario A: Break the Kubelet

This simulates a node failing, causing pods to become orphaned and the node to enter a `NotReady` state.

1. SSH into one of your worker nodes (e.g., `ssh worker-node-1`).
2. Stop the kubelet service:
   ```bash
   sudo systemctl stop kubelet
   ```
3. Exit back to your control plane and run `kubectl get nodes`. Wait about 40 seconds, and you will see the node switch to `NotReady`.

**To fix it:** SSH back into the worker and run `sudo systemctl start kubelet`.

---

## Scenario B: Break CoreDNS

This simulates DNS resolution failing across the entire cluster.

**Option 1: Scale to zero**
```bash
kubectl scale deployment coredns -n kube-system --replicas=0
```

**Option 2: Break the ConfigMap (Harder)**
```bash
kubectl get cm coredns -n kube-system -o yaml | sed 's/kubernetes/brokennet/g' | kubectl apply -f -
# Then restart the pods to pick up the bad config
kubectl rollout restart deployment coredns -n kube-system
```

**To test it's broken:**
```bash
kubectl run test-dns --image=busybox --rm -it -- nslookup kubernetes
```
*(This command will time out or fail).*

---

## Scenario C: Break kube-proxy

This simulates a routing failure. Pods will be running, but Services will refuse connections.

1. Edit the `kube-proxy` DaemonSet to use a fake image version so the pods crash:
   ```bash
   kubectl set image ds/kube-proxy -n kube-system kube-proxy=registry.k8s.io/kube-proxy:v99.9.9
   ```
2. Run `kubectl get pods -n kube-system`. You will see all the `kube-proxy` pods stuck in `ImagePullBackOff`.

**To fix it:** Edit the DaemonSet (`kubectl edit ds kube-proxy -n kube-system`) and fix the image version back to the correct version for your cluster.

---

## Scenario D: API Server Audit Logs (Setup)

For this scenario, the cluster isn't "broken", but you need to turn on Audit Logging so you have logs to investigate.

1. On your control-plane node, create an audit policy file at `/etc/kubernetes/audit-policy.yaml`:
   ```yaml
   apiVersion: audit.k8s.io/v1
   kind: Policy
   rules:
   - level: Metadata
   ```

2. Edit `/etc/kubernetes/manifests/kube-apiserver.yaml` and add these flags to the `kube-apiserver` container command:
   ```yaml
   - --audit-policy-file=/etc/kubernetes/audit-policy.yaml
   - --audit-log-path=/var/log/audit/audit.log
   ```

3. Ensure the volumes are mounted at the bottom of the `kube-apiserver.yaml` file so the static pod can access the host directory:
   ```yaml
   # Under volumeMounts:
     - mountPath: /etc/kubernetes/audit-policy.yaml
       name: audit-policy
       readOnly: true
     - mountPath: /var/log/audit
       name: audit-logs
       readOnly: false

   # Under volumes:
     - hostPath:
         path: /etc/kubernetes/audit-policy.yaml
         type: FileOrCreate
       name: audit-policy
     - hostPath:
         path: /var/log/audit
         type: DirectoryOrCreate
       name: audit-logs
   ```

Wait for the API server to restart, then try deleting a pod. You can now tail `/var/log/audit/audit.log` to practice searching the JSON logs!
