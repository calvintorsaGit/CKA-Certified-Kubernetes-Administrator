# Question 15: Taints & Tolerations

## Context
> *Task:*
> 1. *Add a taint to `node01` so that no normal pods can be scheduled in the node.*
> 2. *Key=`IT` Value=`Kiddie` Type=`NoSchedule`*
> 3. *Schedule a Pod on `node01` adding the correct toleration to the spec and ensure that it lands on the correct node.*

---

## 🛠️ Playground Setup
*(Note: To fully test this in a playground, your cluster must have a worker node explicitly named `node01`. If you only have one node named something else, substitute `node01` with your actual node name when practicing).*

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This question tests your ability to apply taints imperatively and configure pods declaratively. It also includes a subtle but common CKA trick regarding pod placement.

### Step 1: Taint the Node
Use the `kubectl taint` command to apply the taint to `node01` using the exact Key, Value, and Effect (Type) specified.

```bash
kubectl taint nodes node01 IT=Kiddie:NoSchedule
```
*(Tip: If you ever make a typo and need to remove a taint, run the exact same command but append a minus sign `-` at the very end).*

### Step 2: Generate the Pod Manifest
Generate a basic pod manifest using an imperative command and output it to a YAML file. We will edit this file to add the toleration.

```bash
kubectl run tolerant-pod --image=nginx --dry-run=client -o yaml > pod.yaml
```

### Step 3: Add Toleration and Node Affinity (The Trick)
Open `pod.yaml` in your editor. You need to add the `tolerations` block under `spec`. 

**🚨 CRITICAL EXAM TRICK:** The prompt says to *"ensure that it lands on the correct node"*. A toleration simply *allows* a pod to be scheduled on a tainted node; it does **not** force it to go there. If the cluster has other untainted worker nodes (like a `node02`), the scheduler might place it there instead. 

To guarantee it lands on `node01`, you must also add a `nodeName` (or `nodeSelector`).

Modify `pod.yaml` so the `spec` looks like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerant-pod
spec:
  nodeName: node01 # Forces the pod to land on node01 specifically
  containers:
  - image: nginx
    name: tolerant-pod
  tolerations:     # Allows the pod to tolerate the taint on node01
  - key: "IT"
    operator: "Equal"
    value: "Kiddie"
    effect: "NoSchedule"
```

### Step 4: Apply and Verify
Apply the pod manifest to the cluster:
```bash
kubectl apply -f pod.yaml
```

Verify that the pod is in the `Running` state and specifically check the `NODE` column to confirm you satisfied the entire prompt:
```bash
kubectl get pods -o wide
```
*You should see `tolerant-pod` running successfully, and the `NODE` column must list `node01`.*
