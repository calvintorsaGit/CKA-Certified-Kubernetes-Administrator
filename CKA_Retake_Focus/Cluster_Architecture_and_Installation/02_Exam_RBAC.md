# Exam 02: Restricting Access with RBAC

**Domain:** Cluster Architecture, Installation & Configuration (25%)

## Context
You have just switched to a new context in the exam. 
The prompt tells you:
> *A new developer team needs access to the cluster to monitor their deployments, but they must not be able to modify anything or see resources in other namespaces.*

## Your Task
1. Create a namespace named `development`.
2. Create a ServiceAccount named `dev-monitor` inside the `development` namespace.
3. Create a ClusterRole named `pod-reader` that allows `get`, `watch`, and `list` permissions on `pods` and `services`.
4. Bind the `pod-reader` ClusterRole to the `dev-monitor` ServiceAccount, but restrict the permissions **only** to the `development` namespace.

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up some dummy resources so you can verify your RBAC policy later:

```bash
kubectl create namespace development
kubectl run dev-app --image=nginx -n development
kubectl run prod-app --image=nginx -n default
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

Here is exactly how you should think about and solve this in the exam. 
*Pro-tip: Always use imperative commands for RBAC to save time!*

### Step 1: Create Namespace and ServiceAccount
*(Note: If you ran the setup script, the namespace already exists, but in the exam you might need to create it).*
```bash
kubectl create namespace development
kubectl create serviceaccount dev-monitor -n development
```

### Step 2: Create the ClusterRole
The prompt specifically asked for a `ClusterRole` (which is cluster-wide), targeting `pods` and `services`.
```bash
kubectl create clusterrole pod-reader --verb=get,list,watch --resource=pods,services
```

### Step 3: Bind the Role (The Trick)
**CRITICAL EXAM STEP:** The prompt asked you to bind a *ClusterRole*, but restrict it *only* to the `development` namespace. 
To do this, you must use a **RoleBinding** (which is namespace-scoped), NOT a ClusterRoleBinding.
```bash
kubectl create rolebinding dev-monitor-binding \
  --clusterrole=pod-reader \
  --serviceaccount=development:dev-monitor \
  -n development
```

### Step 4: Verification
In the exam, always verify your RBAC rules using `auth can-i`. It takes 10 seconds and guarantees you get the points.

1. Test if they can read pods in the `development` namespace (Should be **yes**):
   ```bash
   kubectl auth can-i list pods --as=system:serviceaccount:development:dev-monitor -n development
   ```
2. Test if they can read pods in the `default` namespace (Should be **no**, because we used a RoleBinding):
   ```bash
   kubectl auth can-i list pods --as=system:serviceaccount:development:dev-monitor -n default
   ```
3. Test if they can delete pods in the `development` namespace (Should be **no**, because we only gave get,list,watch):
   ```bash
   kubectl auth can-i delete pods --as=system:serviceaccount:development:dev-monitor -n development
   ```
