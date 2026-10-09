# Question 09: NetworkPolicy

## Context
> *There are 2 deployments, Frontend and Backend.*
> 
> *Frontend will be in `frontend` namespace and Backend will be in `backend` namespace.*
> 
> *Task:*
> *Create a network policy to have interaction between frontend and backend deployment. The network policy has to be least permissive.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up the two namespaces and their respective deployments.

```bash
kubectl create namespace frontend
kubectl create namespace backend

kubectl create deployment frontend --image=nginx -n frontend
kubectl create deployment backend --image=nginx -n backend

# Expose backend so there's a target to hit
kubectl expose deployment backend --port=80 -n backend
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

To make the policy "least permissive", we must create an `Ingress` NetworkPolicy in the `backend` namespace. It must strictly target the `backend` pods and only allow traffic originating from the specific `frontend` pods within the `frontend` namespace.

### Step 1: Identify Labels
NetworkPolicies rely entirely on labels. You need to inspect the labels of the pods and namespaces in the exam environment.

1. **Find Backend Pod Labels:**
   ```bash
   kubectl get pods -n backend --show-labels
   ```
   *(Assuming the label is `app=backend`)*

2. **Find Frontend Pod Labels:**
   ```bash
   kubectl get pods -n frontend --show-labels
   ```
   *(Assuming the label is `app=frontend`)*

3. **Find Frontend Namespace Labels:**
   Since Kubernetes 1.21+, namespaces automatically get a label `kubernetes.io/metadata.name: <namespace-name>`. 
   ```bash
   kubectl get ns frontend --show-labels
   ```

### Step 2: Create the Network Policy Manifest
Create a file named `np.yaml`. We apply this to the `backend` namespace to protect the backend.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend   # 1. Target the backend pods
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: frontend # 2a. Select the frontend namespace
      podSelector:
        matchLabels:
          app: frontend                         # 2b. AND specifically select the frontend pods
    ports:
    - protocol: TCP
      port: 80       # 3. Restrict to the specific port the backend listens on (assuming 80)
```
**🚨 CRITICAL EXAM TIP:** Notice that `namespaceSelector` and `podSelector` are under the *same* hyphen (`-`) list item in the `from:` array. This creates a logical **AND** condition. If they were separated by hyphens, it would be an **OR** condition (which would be highly permissive and fail the question).

### Step 3: Apply the Policy
```bash
kubectl apply -f np.yaml
```

### Step 4: Verification (Optional but recommended)
You can test the connection by exec-ing into the frontend pod and curling the backend service.
```bash
# This should succeed
kubectl exec -it deploy/frontend -n frontend -- curl -m 3 http://backend.backend.svc.cluster.local

# This should timeout (from a different namespace)
kubectl run test-pod --image=busybox --restart=Never --rm -it -- wget -T 3 http://backend.backend.svc.cluster.local
```
