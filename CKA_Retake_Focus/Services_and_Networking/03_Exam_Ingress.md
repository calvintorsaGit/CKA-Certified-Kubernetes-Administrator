# Exam 03: Routing Traffic with Ingress

**Domain:** Services and Networking (20%)

## Context
You have just switched to a new context in the exam. 
The prompt tells you:
> *You need to expose two existing backend microservices to the outside world using a single Ingress resource.*

## Your Task
1. Create an Ingress resource named `web-ingress` in the `default` namespace.
2. Any HTTP traffic to the host `shopping.local` on the path `/cart` should be routed to the existing service named `cart-service` on port `80`.
3. Any HTTP traffic to the host `shopping.local` on the path `/pay` should be routed to the existing service named `payment-service` on port `8080`.
4. Ensure both paths are evaluated using the `Prefix` path type.

---

## 🛠️ Playground Setup
Run this block in your playground to spin up the dummy backend deployments and services so you have something to route traffic to:

```bash
kubectl create deployment cart-app --image=nginx
kubectl expose deployment cart-app --name=cart-service --port=80

kubectl create deployment payment-app --image=nginx
kubectl expose deployment payment-app --name=payment-service --port=8080
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

Here is exactly how you should think about and solve this in the exam.
While you *can* create an Ingress imperatively, the syntax is tricky. It is usually faster to generate a dry-run YAML, edit it, and apply it.

### Step 1: Generate the base YAML
Use the `kubectl create ingress` command with the `--dry-run` flag to generate a solid template. This saves you from having to memorize the `apiVersion` and indentation structure:

```bash
kubectl create ingress web-ingress \
  --rule="shopping.local/cart*=cart-service:80" \
  --rule="shopping.local/pay*=payment-service:8080" \
  --dry-run=client -o yaml > ingress.yaml
```
*(Fun fact: Adding the `*` at the end of the path tells kubectl to automatically set the `pathType` to `Prefix`!)*

### Step 2: Review and Apply
Open the generated `ingress.yaml` file to make sure it looks correct:
```bash
vi ingress.yaml
```

It should look like this:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  namespace: default
spec:
  rules:
  - host: shopping.local
    http:
      paths:
      - backend:
          service:
            name: cart-service
            port:
              number: 80
        path: /cart
        pathType: Prefix
      - backend:
          service:
            name: payment-service
            port:
              number: 8080
        path: /pay
        pathType: Prefix
```

Apply the file:
```bash
kubectl apply -f ingress.yaml
```

### Step 3: Verification
Verify the Ingress was created and is pointing to the correct backends:
```bash
kubectl describe ingress web-ingress
```
You should see the `Rules` table clearly routing `shopping.local/cart` to `cart-service:80` and `shopping.local/pay` to `payment-service:8080`.
