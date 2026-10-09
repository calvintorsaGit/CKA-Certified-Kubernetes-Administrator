# Exam 09: Control Plane Failure (API Server)

**Domain:** Troubleshooting (30%)

## Context
> *You just switched to a new context, but every `kubectl` command you run hangs or returns "The connection to the server... was refused". The API server is completely down.*

## Your Task
1. Investigate the control plane node to find out why the Kubernetes API server is failing to start.
2. Fix the configuration issue.
3. Verify that `kubectl get nodes` works again.

---

## 🛠️ Playground Setup
Run this on your control plane node to break the API server:
```bash
# Inject a typo into the command argument
sed -i 's/kube-apiserver/kube-apisrver/g' /etc/kubernetes/manifests/kube-apiserver.yaml
```
*(Wait 30-60 seconds for the API server pod to crash, then `kubectl` will stop working).*
<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Bypassing Kubectl
Since `kubectl` is broken, you must use container runtime commands directly on the control plane node.
1. SSH into the control plane node.
2. Check running and exited containers using `crictl`:
   ```bash
   crictl ps -a | grep apiserver
   ```
   *(You will see the apiserver container keeps exiting).*
3. Check the logs of the crashed container:
   ```bash
   crictl logs <container-id>
   ```
   *(You will see an error like: "executable file not found in $PATH: kube-apisrver").*

### Step 2: Fixing Static Pods
The API server is a static pod managed by the kubelet. Its configuration lives in a specific directory.
1. Navigate to the manifests directory:
   ```bash
   cd /etc/kubernetes/manifests/
   ```
2. Edit the API server manifest:
   ```bash
   vi kube-apiserver.yaml
   ```
3. Locate the typo (`kube-apisrver`) in the `command:` array and correct it to `kube-apiserver`. Save and exit.

### Step 3: Verification
The kubelet constantly watches the `/etc/kubernetes/manifests` directory. Once you save the file, it will automatically recreate the API server pod.
Wait 30-60 seconds, then try:
```bash
kubectl get nodes
```
