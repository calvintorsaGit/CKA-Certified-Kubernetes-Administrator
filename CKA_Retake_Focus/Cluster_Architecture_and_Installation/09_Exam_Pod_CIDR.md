# Exam 09: Identify Cluster-wide Pod CIDR

**Domain:** Cluster Architecture, Installation & Configuration (25%)

## Context
> *While preparing to install a CNI plugin on your Kubernetes cluster, you typically need to confirm the cluster-wide Pod network CIDR. Identify the Pod subnet configured for the cluster (the value specified under podSubnet in the kubeadm configuration).*

## Your Task
1. Identify the Pod subnet configured for the cluster.
2. Output this CIDR in the format `x.x.x.x/x` to a file located at `/root/pod-cidr.txt`.

**Note:** Use the cluster-wide `podSubnet` from the `kubeadm-config` ConfigMap, not the per-node CIDR from `kubectl get node`.

---

## ✅ Solution & Discussion

Here is the step-by-step solution to find the cluster-wide Pod CIDR and write it to the required file.

### Step 1: Inspect the `kubeadm-config` ConfigMap
The cluster configuration, including networking details like the `podSubnet`, is stored in the `kubeadm-config` ConfigMap within the `kube-system` namespace. You can inspect it by outputting it as YAML:

```bash
kubectl get configmap kubeadm-config -n kube-system -o yaml | grep podSubnet
```
*Example Output:*
```yaml
      podSubnet: 10.244.0.0/16
```

### Step 2: Write the CIDR to the file
Once you have identified the CIDR block (e.g., `10.244.0.0/16`), write it to the specified file. Replace `10.244.0.0/16` with the actual value you found in your cluster.

```bash
echo "10.244.0.0/16" > /root/pod-cidr.txt
```

### Step 3: Verification
Verify that the cluster-wide Pod CIDR network is correctly written to the file:

```bash
cat /root/pod-cidr.txt
```
*Expected Output:*
```
10.244.0.0/16
```
