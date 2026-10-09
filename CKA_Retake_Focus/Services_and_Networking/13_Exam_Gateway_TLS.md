# Exam 13: Configuring TLS on a Gateway

**Domain:** Services and Networking (20%)

## Context
You have an existing Gateway API `Gateway` resource. You need to secure it by adding an HTTPS listener that uses a TLS certificate stored in a Kubernetes Secret. 

*(Note: Gateway API is the modern successor to Ingress. In the Gateway API, TLS is configured directly on the `Gateway` listeners, rather than on the routing rules).*

## Your Task
Modify the existing `web-gateway` in the `cka5673` namespace to handle HTTPS traffic on port `443` for `kodekloud.com`, using a TLS certificate stored in a secret named `kodekloud-tls`.

Validation checks to keep in mind:
* Is the web gateway configured to listen on the hostname `kodekloud.com`?
* Is the HTTPS listener configured with the correct TLS certificate?

---

## 🛠️ Playground Setup
Run this block to create the dummy namespace, TLS secret, GatewayClass, and the initial insecure Gateway:

```bash
# 1. Install Gateway API CRDs (if not already installed)
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# 2. Create the namespace
kubectl create namespace cka5673

# 3. Create a dummy TLS secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=kodekloud.com/O=kodekloud"
kubectl create secret tls kodekloud-tls --key /tmp/tls.key --cert /tmp/tls.crt -n cka5673

# 4. Create a dummy GatewayClass
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gateway-class
spec:
  controllerName: example.com/gateway-controller
EOF

# 5. Create the existing insecure Gateway
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: cka5673
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: "kodekloud.com"
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Edit the Gateway
You need to modify the existing `web-gateway` object to add the HTTPS listener. The easiest way is to use `kubectl edit`:

```bash
kubectl edit gateway web-gateway -n cka5673
```

### Step 2: Add the HTTPS Listener
Find the `listeners` array in the YAML. You need to add a new listener for HTTPS on port `443`, specifying the `kodekloud.com` hostname and referencing the `kodekloud-tls` secret.

Your modified `spec` should look like this:

```yaml
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: http                # (You can leave the old HTTP listener, or replace it)
    protocol: HTTP
    port: 80
    hostname: "kodekloud.com"
  - name: https               # <-- ADD THIS NEW LISTENER
    protocol: HTTPS
    port: 443
    hostname: "kodekloud.com"
    tls:
      mode: Terminate
      certificateRefs:
      - name: kodekloud-tls
```

### Step 3: Verify the Configuration

Verify that your changes were applied correctly by checking the output of the Gateway:

```bash
kubectl get gateway web-gateway -n cka5673 -o yaml
```

**Mental Checklist:**
- [x] Does it have a listener with `protocol: HTTPS`?
- [x] Is the port `443`?
- [x] Is the hostname `kodekloud.com`?
- [x] Under `tls: certificateRefs:`, does it list `name: kodekloud-tls`?

If yes, you have successfully configured TLS termination on the Gateway!
