# Question 16: NodePort Service

## Context
> *There is a deployment named `nodeport-deployment` in the `relative` namespace.*
> 
> *Tasks:*
> 1. *Configure the deployment so it can be exposed using port `80` and protocol `TCP` name `http`.*
> 2. *Create a new Service named `nodeport-service` exposing the container port `80` and `TCP`.*
> 3. *Configure the new Service to also expose the individual pods using `NodePort`.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up the namespace and the base deployment that you need to modify and expose.

```bash
kubectl create namespace relative
kubectl create deployment nodeport-deployment --image=nginx -n relative
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This is a two-part question: first, you need to edit the pod template within the deployment to explicitly declare the container port. Then, you need to expose that deployment to the outside world via a NodePort Service.

### Step 1: Configure the Deployment Port
When a deployment is created quickly, the `ports` array isn't always explicitly defined in the manifest. We need to edit the deployment to add this declaration.

```bash
kubectl edit deployment nodeport-deployment -n relative
```

Find the `containers` block inside `spec.template.spec` and add the `ports` array to match the requirements (port `80`, protocol `TCP`, name `http`):

```yaml
    spec:
      containers:
      - image: nginx
        name: nginx
        # ADD THIS BLOCK:
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
```
Save and exit the editor. The deployment will roll out the updated pods.

### Step 2 & 3: Create the NodePort Service
The fastest, most error-free way to create a service that exposes a deployment is using the `kubectl expose` imperative command. This command fulfills both Task 2 (creating the service) and Task 3 (making it a NodePort) simultaneously.

```bash
kubectl expose deployment nodeport-deployment \
  --name=nodeport-service \
  --port=80 \
  --target-port=80 \
  --protocol=TCP \
  --type=NodePort \
  --namespace=relative
```

*(Note: `--target-port=80` and `--protocol=TCP` are the defaults for `kubectl expose`, but it's good practice to be explicit to ensure you meet exam requirements).*

### Step 4: Verification
Verify that the service was created successfully and that it was assigned a node port (a port in the 30000-32767 range).

```bash
kubectl get svc nodeport-service -n relative
```

*Expected Output:*
```text
NAME               TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nodeport-service   NodePort   10.96.123.456   <none>        80:31234/TCP   10s
```
*(Notice the `80:31234/TCP` mapping. The `31234` is the NodePort that exposes the individual pods to the outside of the cluster).*
