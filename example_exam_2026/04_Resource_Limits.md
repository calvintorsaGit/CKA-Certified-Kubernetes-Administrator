# Question 04: Resource Requests & Limits

## Context
> *You are managing a WordPress application running in a Kubernetes cluster.*
> *Your task is to adjust the Pod resource requests and limits to ensure stable operation. Follow the instructions below:*
> 
> 1. *Scale down the `wordpress` Deployment to 0 replicas.*
> 2. *Edit the Deployment and divide node resources evenly across all 3 Pods.*
> 3. *Assign fair and equal CPU and memory requests to each Pod.*
> 4. *Add sufficient overhead to avoid node instability.*
> 
> *Ensure that both the init containers and main containers use exactly the same resource requests and limits.*
> 
> *After making the changes, scale the Deployment back to 3 replicas.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up a mock `wordpress` deployment that includes an init container.

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 3
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-db
        image: busybox
        command: ['sh', '-c', 'echo "Initializing..."']
      containers:
      - name: wordpress
        image: busybox
        command: ['sh', '-c', 'sleep 3600']
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This question tests your ability to read node capacity, calculate limits, and apply identical configurations to multiple container types within a single Pod.

### Step 1: Scale Down to 0 Replicas
```bash
kubectl scale deployment wordpress --replicas=0
```

### Step 2: Calculate Node Resources & Overhead
You need to find the `Allocatable` resources of the worker node where these pods will run.
```bash
kubectl get nodes
kubectl describe node <worker-node-name> | grep -A 5 "Allocatable:"
```
*Example Output:*
```yaml
Allocatable:
  cpu:                3
  memory:             3000Mi
```

**Calculation:**
- Total capacity is `3000m` CPU and `3000Mi` Memory.
- To "add sufficient overhead to avoid node instability", you shouldn't use 100% of the node. Let's reserve roughly 10% for overhead: leaves `2700m` CPU and `2700Mi` Memory.
- "Divide evenly across all 3 Pods": `2700m / 3 = 900m` CPU per pod. `2700Mi / 3 = 900Mi` Memory per pod.

*(Note: In the real exam, just ensure you leave a small logical buffer and divide the rest evenly).*

### Step 3: Edit the Deployment
Now, edit the deployment to inject the calculated resources.
```bash
kubectl edit deployment wordpress
```

Find the `initContainers` block and the `containers` block. Add the exact same `resources` definition to BOTH:

```yaml
      initContainers:
      - name: init-db
        image: busybox
        command: ['sh', '-c', 'echo "Initializing..."']
        resources:
          requests:
            cpu: "900m"
            memory: "900Mi"
          limits:
            cpu: "900m"
            memory: "900Mi"
      containers:
      - name: wordpress
        image: busybox
        command: ['sh', '-c', 'sleep 3600']
        resources:
          requests:
            cpu: "900m"
            memory: "900Mi"
          limits:
            cpu: "900m"
            memory: "900Mi"
```

### Step 4: Scale Back Up
Once saved, scale the deployment back up to 3 replicas as instructed.
```bash
kubectl scale deployment wordpress --replicas=3
```

Verify that the pods start correctly and aren't stuck in `Pending` (which would indicate you requested more resources than the node can allocate).
```bash
kubectl get pods
```
