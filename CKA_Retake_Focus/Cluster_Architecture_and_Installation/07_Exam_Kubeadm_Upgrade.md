# Exam 07: Kubeadm Upgrade

**Domain:** Cluster Architecture, Installation & Configuration (25%)

## Context
> *Your control plane node is running an older minor version of Kubernetes. You need to upgrade the kubeadm cluster.*

## Your Task
1. Drain the control plane node to prepare it for maintenance.
2. Upgrade `kubeadm` to the next available minor version (or a specific version requested in the exam).
3. Upgrade the control plane components using `kubeadm upgrade apply`.
4. Uncordon the node when finished.
*(You do not need to upgrade the worker nodes for this specific task).*

---

## 🛠️ Playground Setup
No setup required, but must be done on a real cluster control plane node.
<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Drain the node
```bash
# Get the node name
kubectl get nodes

# Drain it (ignoring daemonsets is usually required)
kubectl drain <control-plane-node-name> --ignore-daemonsets --delete-emptydir-data
```

### Step 2: Upgrade kubeadm
```bash
# Find available versions
apt update
apt-cache madison kubeadm

# Unhold and install the specific version (e.g. 1.30.0-1.1)
apt-mark unhold kubeadm
apt-get install -y kubeadm=1.30.0-1.1
apt-mark hold kubeadm
```

### Step 3: Upgrade the Control Plane
```bash
# Plan the upgrade to verify versions
kubeadm upgrade plan

# Apply the upgrade (replace v1.30.0 with your target)
kubeadm upgrade apply v1.30.0
```

### Step 4: Upgrade kubelet and kubectl (Optional but recommended)
```bash
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.30.0-1.1 kubectl=1.30.0-1.1
apt-mark hold kubelet kubectl
systemctl daemon-reload
systemctl restart kubelet
```

### Step 5: Uncordon
```bash
kubectl uncordon <control-plane-node-name>
```
