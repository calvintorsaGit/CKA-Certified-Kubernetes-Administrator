# Question 03: Gateway API Migration

## Context
> *You have an existing web application deployed in a Kubernetes cluster using an Ingress resource named `web`. You must migrate the existing Ingress configuration to the new Kubernetes Gateway API, maintaining the existing HTTPS access configuration.*
> 
> *Tasks:*
> 1. *Create a `Gateway` resource named `web-gateway` with hostname `gateway.web.k8s.local` that maintains the existing TLS and listener configuration from the existing Ingress resource named `web`.*
> 2. *Create an `HTTPRoute` resource named `web-route` with hostname `gateway.web.k8s.local` that maintains the existing routing rules from the current Ingress resource named `web`.*
> 
> *Note: A `GatewayClass` named `nginx-class` is already installed in the cluster.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up the mock Ingress, Service, Secret, and GatewayClass, so you can test migrating it to the Gateway API.

```bash
# Install Gateway API CRDs first
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

kubectl create secret generic web-tls-secret --from-literal=tls.crt="dummy-cert" --from-literal=tls.key="dummy-key"

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-class
spec:
  controllerName: k8s.io/ingress-nginx
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: web
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
spec:
  tls:
  - hosts:
    - gateway.web.k8s.local
    secretName: web-tls-secret
  rules:
  - host: gateway.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

To migrate from an Ingress to the Gateway API, you need to split the configuration into a `Gateway` (which handles the listener port and TLS) and an `HTTPRoute` (which handles the hostnames, paths, and backend routing).

### Step 1: Inspect the Existing Ingress
Before creating the new resources, inspect the existing Ingress to see what needs to be migrated:
```bash
kubectl get ingress web -o yaml
```
You will notice:
- **Hostname:** `gateway.web.k8s.local`
- **TLS Secret:** `web-tls-secret`
- **Backend Service:** `web-service` on port `80`
- **Path:** `/`

### Step 2: Create the Gateway
Create a file named `gateway.yaml` for the `Gateway` resource. It must reference the `nginx-class` GatewayClass and handle HTTPS using the existing TLS secret.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
spec:
  gatewayClassName: nginx-class
  listeners:
  - name: https
    hostname: gateway.web.k8s.local
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - name: web-tls-secret
```
Apply it:
```bash
kubectl apply -f gateway.yaml
```

### Step 3: Create the HTTPRoute
Create a file named `httproute.yaml` for the `HTTPRoute` resource. It must attach to `web-gateway` and forward traffic to `web-service`.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - "gateway.web.k8s.local"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-service
      port: 80
```
Apply it:
```bash
kubectl apply -f httproute.yaml
```

### Step 4: Verification
Verify both resources are created and linked correctly.
```bash
kubectl get gateway web-gateway
kubectl get httproute web-route
```
*(Note: They may not show as `Programmed` or `Accepted` in a playground environment unless a real Gateway API controller matching the GatewayClass is actively running).*
