# Exam 08: Services and DNS Resolution

**Domain:** Services and Networking (20%)

## Context
> *An internal API needs to be exposed within the cluster so other applications can communicate with it via DNS.*

## Your Task
1. Create a Deployment named `auth-api` using the `nginx:alpine` image with 2 replicas in the `auth` namespace.
2. Expose the deployment via a ClusterIP service named `auth-service` on port `8080`, targeting port `80` on the pods.
3. Spin up a temporary busybox pod in the `default` namespace and successfully perform an `nslookup` on the newly created service.

---

## 🛠️ Playground Setup
```bash
kubectl create namespace auth
```
<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Create the Deployment
```bash
kubectl create deployment auth-api --image=nginx:alpine --replicas=2 -n auth
```

### Step 2: Expose the Deployment
Using the imperative command is the fastest and safest way:
```bash
kubectl expose deployment auth-api \
  --name=auth-service \
  --port=8080 \
  --target-port=80 \
  --type=ClusterIP \
  -n auth
```

### Step 3: Verify DNS
To query a service in a different namespace, you must use the Fully Qualified Domain Name (FQDN) format: `<service>.<namespace>`.
```bash
# Run a temporary pod to test
kubectl run dns-test --image=busybox:1.35.0 --rm -it --restart=Never -- sh

# Inside the busybox shell:
nslookup auth-service.auth
exit
```
