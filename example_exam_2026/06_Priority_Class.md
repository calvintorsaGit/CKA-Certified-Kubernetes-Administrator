# Question 06: Priority Class

## Context
> *You're working in a Kubernetes cluster with an existing Deployment named `busybox-logger` running in a namespace called `priority`.*
> 
> *The cluster already has at least one user-defined Priority Class.*
> 
> *Perform the following tasks:*
> 1. *Create a new Priority Class named `high-priority` for user workloads. The value of this Priority Class should be exactly one less than the highest existing user-defined Priority Class value.*
> 2. *Patch the existing Deployment `busybox-logger` in the `priority` namespace to use the newly created `high-priority` Priority Class.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up the mock namespace, deployment, and the existing user-defined Priority Class.

```bash
kubectl create namespace priority

kubectl create deployment busybox-logger --image=busybox -n priority -- /bin/sh -c "while true; do echo log; sleep 5; done"

kubectl apply -f - <<EOF
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: existing-highest-priority
value: 50000
globalDefault: false
description: "An existing user-defined priority class."
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This scenario requires you to query cluster-wide resources (`PriorityClass`), perform a simple calculation, and patch an existing workload.

### Step 1: Find the Highest User-Defined Priority Class Value
First, list all PriorityClasses in the cluster to identify the highest user-defined value. Note that `system-node-critical` and `system-cluster-critical` are built-in system classes with values of 2,000,000,000 and 2,000,001,000, respectively—ignore these.

```bash
kubectl get priorityclasses
```
*Example Output:*
```text
NAME                        VALUE        GLOBAL-DEFAULT   AGE
existing-highest-priority   50000        false            2m
system-cluster-critical     2000000000   false            10d
system-node-critical        2000001000   false            10d
```
The highest user-defined value here is `50000`. Therefore, your new Priority Class value should be exactly one less: **`49999`**.

### Step 2: Create the New Priority Class
Create a YAML manifest named `pc.yaml` for the new Priority Class.

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 49999
globalDefault: false
description: "High priority for user workloads"
```

Apply it to the cluster:
```bash
kubectl apply -f pc.yaml
```

### Step 3: Patch the Deployment
You must add the `priorityClassName` field to the **Pod template** (`spec.template.spec`) within the deployment.

You can do this using `kubectl edit`:
```bash
kubectl edit deployment busybox-logger -n priority
```
Add the field inside the pod spec:
```yaml
    spec:
      priorityClassName: high-priority
      containers:
      - image: busybox
```

**Alternatively, use `kubectl patch` (faster):**
```bash
kubectl patch deployment busybox-logger -n priority -p '{"spec": {"template": {"spec": {"priorityClassName": "high-priority"}}}}'
```

### Step 4: Verification
Verify that the pods in the deployment have been recreated with the new Priority Class:
```bash
kubectl get pods -n priority -o custom-columns=NAME:.metadata.name,PRIORITY_CLASS:.spec.priorityClassName
```
*Expected Output:*
```text
NAME                              PRIORITY_CLASS
busybox-logger-86d7c7c7f5-xxxxx   high-priority
```
