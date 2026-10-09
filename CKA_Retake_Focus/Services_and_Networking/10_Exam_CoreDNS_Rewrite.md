# Exam 10: CoreDNS Custom Configuration

**Domain:** Services and Networking (20%)

## Context
> *Your cluster needs to resolve domains for an external legacy network.*

## Your Task
1. Modify the CoreDNS configuration so that any DNS query for `*.legacy.local` is rewritten to `cluster.local`.
2. Do not modify the existing `kubernetes` plugin configuration block.
3. Test the resolution by spinning up a temporary pod and querying `api.legacy.local`.

---

## 🛠️ Playground Setup
No setup required, just a running cluster!
<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Edit the CoreDNS ConfigMap
CoreDNS configuration is stored in the `coredns` ConfigMap in the `kube-system` namespace.
```bash
kubectl edit configmap coredns -n kube-system
```

### Step 2: Add the Rewrite Rule
Locate the `.:53 {` block in the `Corefile` data. Add the `rewrite` plugin rule immediately inside it:

```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        rewrite name suffix legacy.local cluster.local   # <-- ADD THIS LINE
        errors
        health {
           lameduck 5s
        }
        ...
```
Save and exit. CoreDNS will automatically reload its configuration within a minute.

### Step 3: Test Verification
Spin up a busybox pod and test the nslookup:
```bash
kubectl run test-dns --image=busybox:1.35.0 --rm -it --restart=Never -- sh

# Inside the busybox shell, test the rewrite:
nslookup kubernetes.default.svc.legacy.local
```
*(This should resolve to the same IP as `kubernetes.default.svc.cluster.local`, proving the rewrite was successful).*
