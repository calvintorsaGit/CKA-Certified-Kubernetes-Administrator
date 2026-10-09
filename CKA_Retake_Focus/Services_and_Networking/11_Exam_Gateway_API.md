# Exam 11: Migrating Ingress to Gateway API

**Domain:** Services & Networking (20%)

## Context
Your team is migrating from the legacy Kubernetes `Ingress` object to the newer **Gateway API**. You have an existing `Ingress` routing traffic to two services, but you need to replace it with a `Gateway` and an `HTTPRoute`.

> *Note: While `Ingress` is heavily tested on the CKA, the `Gateway API` is the modern successor. It is a fantastic concept to understand for modern Kubernetes networking!*

## Your Task
1. Inspect the existing `Ingress` named `web-ingress` in the `web-store` namespace. It routes traffic for `shopping.local` to `/cart` and `/pay`.
2. Create a `Gateway` named `shopping-gateway` in the `web-store` namespace that listens on port `80` (HTTP) and uses the GatewayClass `example-gateway-class`.
3. Create an `HTTPRoute` named `shopping-route` in the `web-store` namespace that:
   - Attaches to the `shopping-gateway` you just created.
   - Routes `shopping.local/cart` to the `cart-service` on port `80`.
   - Routes `shopping.local/pay` to the `payment-service` on port `8080`.
4. Delete the old `Ingress` object once the `HTTPRoute` is created.

---

## 🛠️ Playground Setup
Run this block to create the existing resources and install the Gateway API CRDs (since they don't come installed on base k8s clusters yet):

```bash
# 1. Install the Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

# 2. Create the namespace and services
kubectl create namespace web-store
kubectl create deployment cart-service --image=nginx -n web-store
kubectl expose deployment cart-service --port=80 -n web-store
kubectl create deployment payment-service --image=nginx -n web-store
kubectl expose deployment payment-service --port=8080 -n web-store

# 3. Create a dummy GatewayClass
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gateway-class
spec:
  controllerName: example.com/gateway-controller
EOF

# 4. Create the legacy Ingress that you need to migrate
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: web-store
spec:
  rules:
  - host: shopping.local
    http:
      paths:
      - path: /cart
        pathType: Prefix
        backend:
          service:
            name: cart-service
            port:
              number: 80
      - path: /pay
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 8080
EOF
```

---

## ✅ Solution & Discussion

Here is the step-by-step solution to complete the migration.

### Step 1: Create the Gateway
The Gateway defines *where* and *how* traffic enters the cluster (port, protocol, and hostname).

1. Create a file named `gateway.yaml`:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shopping-gateway
  namespace: web-store
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    hostname: "shopping.local"
```
2. Apply it: `kubectl apply -f gateway.yaml`

### Step 2: Create the HTTPRoute
The HTTPRoute defines the actual routing rules (like the paths in the Ingress), and attaches itself to a Gateway.

1. Create a file named `route.yaml`:
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: shopping-route
  namespace: web-store
spec:
  parentRefs:
  - name: shopping-gateway
  hostnames:
  - "shopping.local"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /cart
    backendRefs:
    - name: cart-service
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /pay
    backendRefs:
    - name: payment-service
      port: 8080
```
2. Apply it: `kubectl apply -f route.yaml`

### Step 3: Delete the old Ingress
Now that the new Gateway API resources are handling the traffic, you can safely remove the legacy Ingress.
```bash
kubectl delete ingress web-ingress -n web-store
```

### Discussion
The Gateway API splits the old monolithic `Ingress` object into separate, distinct pieces:
1. **GatewayClass:** Created by cluster operators to define the underlying infrastructure.
2. **Gateway:** Defines a network endpoint (ports, protocols).
3. **HTTPRoute (and other routes):** Defined by application developers to route traffic to their specific services. 

This split is what makes Gateway API much more powerful and flexible for larger teams than the old `Ingress` standard!
