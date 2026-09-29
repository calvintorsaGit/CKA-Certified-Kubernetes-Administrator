# Exercise 33 — NGINX SSL Protocols Update

> **Medium** | ~15 min | Domain: Cluster Architecture (25%)
>
> Related: [README — Cluster Architecture](../../README.md#domain-4--cluster-architecture-installation--configuration-25)

A common exam scenario is updating a raw NGINX configuration file hosted inside a ConfigMap to support legacy TLS versions, without breaking modern ones.

## Setup Environment

Run this command to create the broken scenario you will be tested on:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: exercise-33
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: exercise-33
data:
  nginx.conf: |
    events {}
    http {
      server {
        listen 443; # Intentionally omitting 'ssl' keyword so NGINX doesn't crash looking for certs
        ssl_protocols TLSv1.3;
        location / { return 200 'OK\n'; }
      }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-web
  namespace: exercise-33
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-web
  template:
    metadata:
      labels:
        app: secure-web
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config
EOF
```

## Tasks

1. The security team requires you to ADD support for `TLSv1.2` to the `secure-web` deployment in the `exercise-33` namespace.
2. Edit the ConfigMap to support both `TLSv1.2` and `TLSv1.3`.
3. Ensure the `secure-web` pods are actually actively using the new configuration.

## Hints

<details>
<summary>Stuck? Click to reveal hints</summary>

- `kubectl edit cm nginx-config -n exercise-33`
- Look for `ssl_protocols TLSv1.3;` and change it to `ssl_protocols TLSv1.2 TLSv1.3;` (Note the space!)
- **Crucial Trap:** Changes to ConfigMaps do not automatically restart pods! You must manually restart the deployment for the NGINX process to read the new file.
- `kubectl rollout restart deployment secure-web -n exercise-33`

</details>

## Verify

```bash
# 1. Check the ConfigMap contents
kubectl get cm nginx-config -n exercise-33 -o yaml | grep ssl_protocols
# Should output: ssl_protocols TLSv1.2 TLSv1.3;

# 2. Check the active config inside the running pod
kubectl exec -n exercise-33 deploy/secure-web -- cat /etc/nginx/nginx.conf | grep ssl_protocols
# Should output: ssl_protocols TLSv1.2 TLSv1.3;
```

## Cleanup

```bash
kubectl delete ns exercise-33
```

<details>
<summary>Solution</summary>

```bash
# 1. Edit the ConfigMap
kubectl edit cm nginx-config -n exercise-33

# Inside the editor, change:
# ssl_protocols TLSv1.3;
# to:
# ssl_protocols TLSv1.2 TLSv1.3;
# Save and exit.

# 2. Restart the deployment so NGINX picks up the new config mounted from the ConfigMap
kubectl rollout restart deployment secure-web -n exercise-33

# 3. Wait for the new pods to be ready
kubectl rollout status deployment secure-web -n exercise-33

# 4. Verify the active configuration inside the pod
kubectl exec -it deploy/secure-web -n exercise-33 -- cat /etc/nginx/nginx.conf | grep ssl_protocols
```

</details>
