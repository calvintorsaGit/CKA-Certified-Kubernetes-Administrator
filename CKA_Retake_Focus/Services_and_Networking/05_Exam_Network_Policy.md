# Exam 05: NetworkPolicy - Default Deny Egress

**Domain:** Services and Networking (20%)

## Context
> *A security audit revealed that pods in the `secure-apps` namespace have unrestricted outbound internet access.*

## Your Task
1. Create a NetworkPolicy named `default-deny-egress` in the `secure-apps` namespace.
2. The policy should apply to ALL pods in the namespace.
3. The policy must drop ALL outbound (egress) traffic, EXCEPT it must allow DNS resolution (UDP port 53) to any destination so pods can still resolve names.

---

## 🛠️ Playground Setup
```bash
kubectl create ns secure-apps
kubectl run test-pod --image=busybox:1.35.0 -n secure-apps -- sleep 3600
```
<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Create the YAML
```bash
nano deny-egress.yaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-egress
  namespace: secure-apps
spec:
  podSelector: {}  # Empty selector matches ALL pods in the namespace
  policyTypes:
  - Egress
  egress:
  - ports:
    - protocol: UDP
      port: 53
```

### Step 2: Apply
```bash
kubectl apply -f deny-egress.yaml
```

### Step 3: Verify
```bash
# DNS should still work (will return an IP or answer)
kubectl exec -n secure-apps test-pod -- nslookup kubernetes.default

# External internet (like pinging google) should fail/timeout
kubectl exec -n secure-apps test-pod -- ping -c 1 8.8.8.8
```
