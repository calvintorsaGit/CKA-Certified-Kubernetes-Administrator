# Question 07: Ingress Resource

## Context
> *Create a new ingress resource named `echo` in `echo-sound` namespace*
> 
> *With the following tasks:*
> 1. *Expose the deployment with a service named `echo-service` on `http://example.org/echo` using Service port `8080` `type=NodePort`.*
> 2. *The availability of Service `echo-service` can be checked using the following command which should return 200:*
>    `curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo`

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to create the namespace and the dummy deployment that you are supposed to expose.

```bash
kubectl create namespace echo-sound

# Deploy a simple echo server that listens on port 8080
kubectl create deployment echo-deploy \
  --image=hashicorp/http-echo \
  --namespace=echo-sound \
  -- -text="hello world" -listen=:8080
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This task requires you to create two resources: a `Service` to expose the deployment, and an `Ingress` to route external HTTP traffic to that service.

### Step 1: Create the NodePort Service
First, identify the name of the deployment running in the namespace (if you used the setup above, it is `echo-deploy`). Expose it using the `kubectl expose` imperative command:

```bash
kubectl expose deployment echo-deploy \
  --name=echo-service \
  --port=8080 \
  --target-port=8080 \
  --type=NodePort \
  --namespace=echo-sound
```

### Step 2: Create the Ingress
The fastest way to create a simple Ingress is using the imperative command:

```bash
kubectl create ingress echo \
  --rule="example.org/echo=echo-service:8080" \
  --namespace=echo-sound
```

**Alternative (YAML Method):**
If you prefer or need to use YAML (e.g., to add annotations later), create an `ingress.yaml` file:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo
  namespace: echo-sound
spec:
  rules:
  - host: example.org
    http:
      paths:
      - path: /echo
        pathType: Prefix # Or Exact, Prefix is usually safer
        backend:
          service:
            name: echo-service
            port:
              number: 8080
```
Then apply it: `kubectl apply -f ingress.yaml`

### Step 3: Verification
In an exam environment, you would test using the provided `curl` command. However, if the exam environment doesn't have local DNS setup for `example.org` pointing to the ingress controller, you can also verify the routing rules directly:

```bash
kubectl describe ingress echo -n echo-sound
```
Ensure that the `Rules` section clearly maps:
- **Host:** `example.org`
- **Path:** `/echo`
- **Backends:** `echo-service:8080`
