# Question 14: Troubleshooting Control Plane

## Context
> *After a cluster migration, the controlplane `kube-apiserver` is not coming up.*
> 
> *Before migration:*
> *`etcd` was external and in HA.*
> 
> *After migration, `kube-apiserver` was pointing to etcd peer port `2380` instead of `2379`.*
> 
> *Fix it.*

---

## 🛠️ Playground Setup
*(Note: To simulate this in a playground, you would need root access to the control plane node. You could purposely break your cluster by editing `/etc/kubernetes/manifests/kube-apiserver.yaml` and changing the `--etcd-servers` port to `2380`. The API server will immediately crash, allowing you to practice fixing it).*

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This troubleshooting scenario tests your knowledge of Kubernetes control plane architecture. `etcd` uses port **`2379`** for client communication (which is what the `kube-apiserver` is to `etcd`) and port **`2380`** for server-to-server peer communication (how `etcd` nodes talk to each other in an HA setup).

### Step 1: Locate the Manifest
The `kube-apiserver` runs as a Static Pod managed by the `kubelet` on the control plane node. Its configuration file is always located in the static pod manifests directory.

SSH into the control plane node (if you aren't already there), and open the manifest:
```bash
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
```

### Step 2: Edit the Configuration
Inside the file, look under the `spec.containers.command` array for the `--etcd-servers` flag. 

Based on the prompt, it will currently look something like this:
```yaml
    - --etcd-servers=https://10.0.0.10:2380,https://10.0.0.11:2380
```

Edit the line to change the port from `2380` back to the correct client port, `2379`:
```yaml
    - --etcd-servers=https://10.0.0.10:2379,https://10.0.0.11:2379
```

Save and exit the file (e.g., `:wq` in `vi`).

### Step 3: Wait and Verify
Because the API server is a static pod, the `kubelet` actively monitors the `/etc/kubernetes/manifests/` directory. As soon as you save the file, the `kubelet` detects the change and automatically restarts the `kube-apiserver` pod. 

Wait a few seconds, and then verify the cluster is responding again:
```bash
kubectl get nodes
```
If `kubectl` responds successfully instead of throwing a `Connection refused` error, you have successfully fixed the API server!
