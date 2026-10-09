# Exam 15: Deployment Scaling Troubleshooting

**Domain:** Troubleshooting (30%)

## Context
> *We have created a new deployment called `nginx-deploy`. Scale the deployment to 3 replicas. Has the number of replicas increased? Troubleshoot and fix the issue.*

## Your Task
1. Scale the `nginx-deploy` deployment to 3 replicas.
2. Observe if the number of replicas has actually increased (e.g., pods being created).
3. Troubleshoot and fix the underlying issue preventing the deployment from scaling.

**Verification Questions:**
- Does the deployment have 3 replicas?

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up a scenario where scaling fails due to a ResourceQuota limit:

```bash
kubectl create namespace scale-test
kubectl config set-context --current --namespace=scale-test

# Create a ResourceQuota that limits the namespace to only 1 Pod
kubectl create quota pod-limit --hard=pods=1

# Create the initial deployment
kubectl create deployment nginx-deploy --image=nginx --replicas=1
```

*(Note: In the actual exam, the issue could also be related to a paused deployment, a misconfigured kube-controller-manager, or node resource exhaustion. This playground simulates a ResourceQuota limit).*

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

Here is the step-by-step solution to troubleshoot and fix a deployment that won't scale.

### Step 1: Scale the Deployment
First, attempt to scale the deployment as requested:

```bash
kubectl scale deployment nginx-deploy --replicas=3
```

### Step 2: Observe the Issue
Check the status of the deployment and the replica set.

```bash
kubectl get deployment nginx-deploy
kubectl get rs
kubectl get pods
```
You will notice that the `DESIRED` count is 3, but the `CURRENT` and `READY` counts are stuck at 1. The new pods are not being created.

### Step 3: Troubleshoot
To find out *why* the pods aren't being created, describe the ReplicaSet managing the pods. The ReplicaSet is responsible for creating the actual Pod objects.

1. Find the ReplicaSet name:
   ```bash
   kubectl get rs
   ```
2. Describe the ReplicaSet:
   ```bash
   kubectl describe rs <nginx-deploy-rs-name>
   ```
Look at the `Events` section at the bottom. You will likely see an error message similar to:
`Error creating: pods "nginx-deploy-xxx-" is forbidden: exceeded quota: pod-limit, requested: pods=1, used: pods=1, limited: pods=1`

### Step 4: Fix the Issue
Now that we know a `ResourceQuota` named `pod-limit` is blocking the creation of new pods, we need to fix it. Depending on the exam context, you might edit or delete the quota.

Let's edit the ResourceQuota to allow more pods (e.g., 5 pods):
```bash
kubectl edit resourcequota pod-limit
```
Change `pods: "1"` to `pods: "5"` and save the file.

Alternatively, if the quota is no longer needed:
```bash
kubectl delete resourcequota pod-limit
```

### Step 5: Verification
Once the quota issue is resolved, the ReplicaSet controller will automatically create the missing pods.

Verify that the deployment now has 3 replicas:
```bash
kubectl get deployment nginx-deploy
kubectl get pods
```
All 3 replicas should now show as `Running` and `Ready`.
