# Security Incident - Network Policies

## Task Description
Solve this question on: `ssh cka7968`

There was a security incident where an intruder was able to access the whole cluster from a single hacked backend Pod.
To prevent this, create a NetworkPolicy called `np-backend` in Namespace `project-snake`. It should allow the `backend-*` Pods **only** to:
- Connect to `db1-*` Pods on port `1111`
- Connect to `db2-*` Pods on port `2222`

Use the app Pod labels in your policy.

---

## Solution Guide

### 1. SSH into the specified node
Ensure you are on the correct node for this task:
```bash
ssh cka7968
```

### 2. Verify Pod Labels
First, it's good practice to verify the exact labels on the pods in the `project-snake` namespace:
```bash
kubectl get pods -n project-snake --show-labels
```
You should see labels similar to `app=backend`, `app=db1`, and `app=db2`.

### 3. Create the NetworkPolicy YAML file
Create a file named `np-backend.yaml` using a text editor (e.g., `nano np-backend.yaml` or `vim np-backend.yaml`):

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: db1
    ports:
    - protocol: TCP
      port: 1111
  - to:
    - podSelector:
        matchLabels:
          app: db2
    ports:
    - protocol: TCP
      port: 2222
```

### 4. Apply the NetworkPolicy
Apply the policy to the cluster:
```bash
kubectl apply -f np-backend.yaml
```

### 5. Test the NetworkPolicy
You can verify the policy by running a `curl` command from one of the backend pods:

**Should SUCCEED:**
```bash
# Get IPs of db1 and db2 pods
kubectl get pods -n project-snake -o wide

# Test connection to db1
kubectl exec -n project-snake <backend-pod-name> -- curl -s -m 2 <db1-pod-ip>:1111

# Test connection to db2
kubectl exec -n project-snake <backend-pod-name> -- curl -s -m 2 <db2-pod-ip>:2222
```

**Should FAIL (Timeout):**
```bash
# Test connection to a vault pod on port 3333
kubectl exec -n project-snake <backend-pod-name> -- curl -s -m 2 <vault-pod-ip>:3333
```

### 6. Return to your main terminal
```bash
exit
```
