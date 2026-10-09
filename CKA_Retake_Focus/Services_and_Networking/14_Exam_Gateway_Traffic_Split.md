# Exam 14: Gateway API Traffic Splitting

**Domain:** Services and Networking (20%)

## Context
> *Configure the `web-route` to split traffic between `web-service` and `web-service-v2`. The configuration should ensure that 80% of the traffic is routed to `web-service` and 20% is routed to `web-service-v2`.*
> 
> *Note: `web-gateway`, `web-service`, and `web-service-v2` have already been created and are available on the cluster.*

## Your Task
1. Create/configure an `HTTPRoute` named `web-route`.
2. Attach it to the existing `web-gateway`.
3. Configure the route to forward traffic to `web-service` with 80% weight and `web-service-v2` with 20% weight.

**Verification Questions:**
- Is the `web-route` deployed as `HTTPRoute`?
- Is the route configured to gateway `web-gateway`?
- Is the route configured to service `web-service`?

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up the dummy resources so you can verify your Gateway API route later:

```bash
# Install Gateway API CRDs first
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: example-gateway-class
spec:
  controllerName: example.com/gateway-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
spec:
  gatewayClassName: example-gateway-class
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Same
---
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: web
---
apiVersion: v1
kind: Service
metadata:
  name: web-service-v2
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: web-v2
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

Here is the step-by-step solution to configure the `HTTPRoute` for traffic splitting.

### Step 1: Create the HTTPRoute Manifest
In the exam, you'll need to know the Gateway API structure. Create a file named `web-route.yaml`.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
spec:
  parentRefs:
  - name: web-gateway
  rules:
  - backendRefs:
    - name: web-service
      port: 80
      weight: 80
    - name: web-service-v2
      port: 80
      weight: 20
```

### Step 2: Apply the Configuration
Apply the `HTTPRoute` to your cluster:

```bash
kubectl apply -f web-route.yaml
```

### Step 3: Verification
Verify that the `HTTPRoute` is configured correctly, fulfilling the exam verification questions:

1. **Is the web-route deployed as HTTPRoute?**
   ```bash
   kubectl get httproute web-route
   ```
2. **Is the route configured to gateway web-gateway?**
   Check the `parentRefs` in the output:
   ```bash
   kubectl describe httproute web-route | grep -A 2 'Parent Refs:'
   ```
3. **Is the route configured to service web-service? (and traffic split correctly)**
   Check the `backendRefs` to ensure weights are 80/20:
   ```bash
   kubectl describe httproute web-route | grep -A 5 'Backend Refs:'
   ```
