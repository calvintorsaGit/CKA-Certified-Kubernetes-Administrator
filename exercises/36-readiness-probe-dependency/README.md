# Exercise 36 — Cross-Pod Readiness Probe Dependency

> Related: [README — Workloads & Scheduling](../../README.md#domain-1--workloads--scheduling-15) | **Updated May 2026**

Configure a Pod whose readiness probe depends on an external service endpoint, and resolve the dependency by creating a backing Pod.

## Tasks

Do the following in Namespace `default`:

1. Create a Pod named `ready-if-service-ready` of image `nginx:1-alpine`.
2. Configure a `LivenessProbe` which simply executes command `true`.
3. Configure a `ReadinessProbe` which checks if `http://service-am-i-ready:80` is reachable (`wget -T2 -O- http://service-am-i-ready:80`).
4. Start the Pod and confirm it isn't ready because of the `ReadinessProbe`.
5. Create a second Pod named `am-i-ready` of image `nginx:1-alpine` with label `id: cross-server-ready`.
6. Confirm the first Pod becomes `READY 1/1`.

<details>
<summary>Solution</summary>

```bash
# 1. Create service-am-i-ready service if not present
kubectl create service clusterip service-am-i-ready --tcp=80:80

# 2. Create ready-if-service-ready pod manifest
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ready-if-service-ready
  namespace: default
spec:
  containers:
  - name: nginx
    image: nginx:1-alpine
    livenessProbe:
      exec:
        command: ["true"]
    readinessProbe:
      exec:
        command: ["wget", "-T2", "-O-", "http://service-am-i-ready:80"]
EOF

# 3. Create backing pod am-i-ready with label id=cross-server-ready
kubectl run am-i-ready --image=nginx:1-alpine -l id=cross-server-ready

# 4. Verify pod transitions to READY 1/1
kubectl get pod ready-if-service-ready -w
```

</details>
