# Exercise 43 — Secret Volume Mounting & Environment Variable Injection

> Related: [README — Workloads & Scheduling](../../README.md#domain-1--workloads--scheduling-15) | **Updated May 2026**

Mount existing Secret files into a Pod filesystem as read-only volumes and map Secret key-values to environment variables.

## Tasks

Create Namespace `secret` and implement:
1. Create existing Secret `/course/11/secret1.yaml` in namespace `secret`.
2. Create Secret `secret2` with `user=user1` and `pass=1234`.
3. Create Pod `secret-pod` (image `busybox:1`, command `sleep 1d`):
   - Mount `secret1` read-only at `/tmp/secret1`.
   - Expose `secret2` keys as environment variables `APP_USER` and `APP_PASS`.

<details>
<summary>Solution</summary>

```bash
kubectl create ns secret
kubectl apply -f /course/11/secret1.yaml -n secret
kubectl create secret generic secret2 --from-literal=user=user1 --from-literal=pass=1234 -n secret

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: secret
spec:
  containers:
  - name: busybox
    image: busybox:1
    command: ["sh", "-c", "sleep 1d"]
    env:
    - name: APP_USER
      valueFrom:
        secretKeyRef:
          name: secret2
          key: user
    - name: APP_PASS
      valueFrom:
        secretKeyRef:
          name: secret2
          key: pass
    volumeMounts:
    - name: secret1-vol
      mountPath: /tmp/secret1
      readOnly: true
  volumes:
  - name: secret1-vol
    secret:
      secretName: secret1
EOF
```

</details>
