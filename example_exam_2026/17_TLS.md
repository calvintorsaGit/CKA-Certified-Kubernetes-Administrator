# Question 17: TLS Configuration & ConfigMaps

## Context
> *There is an existing deployment called `nginx-static` in the `nginx-static` namespace.*
> *The deployment contains a ConfigMap that supports TLSv1.2 and TLSv1.3, and a Secret for TLS.*
> 
> *There is a service called `nginx-static` in the `nginx-static` namespace that is currently exposing the deployment.*
> 
> *Tasks:*
> 1. *Configure the configmap to only support TLSv1.3*
> 2. *Add the IP address of the service in `/etc/hosts` and name `ITKiddie.k8s.local`*
> 3. *Verify that everything is working using the following command:*
>    `curl --tls-max 1.2 https://ITKiddie.k8s.local -k` (TLSv1.2 should not work)
>    `curl --tlsv1.3 https://ITKiddie.k8s.local -k`

---

## 🛠️ Playground Setup
*(Note: To simulate this in a playground, you would need to generate a self-signed TLS secret, write a custom Nginx config map containing the `ssl_protocols` directive, and deploy a pod that mounts both. Since generating certs dynamically is complex, the setup script is omitted here. Focus on the solution steps).*

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This scenario tests your ability to edit live configuration data, restart workloads to apply those changes, and perform basic networking tasks at the node OS level.

### Step 1: Edit the ConfigMap
First, identify the name of the ConfigMap in the namespace.
```bash
kubectl get configmaps -n nginx-static
```
*(Assume the output shows a configmap named `nginx-config`)*.

Edit the ConfigMap imperatively:
```bash
kubectl edit configmap nginx-config -n nginx-static
```

Inside the editor, find the Nginx configuration block (usually stored under a data key like `default.conf`). 
Look for the SSL protocols line:
```nginx
    ssl_protocols TLSv1.2 TLSv1.3;
```
Modify it to **only** support TLSv1.3:
```nginx
    ssl_protocols TLSv1.3;
```
Save and exit your editor.

**🚨 CRITICAL EXAM STEP:** When you update a ConfigMap that is mounted as a volume, it can take Kubernetes several minutes to sync the changes into the running pod. To apply the change immediately and guarantee it works during grading, you **must** restart the deployment.
```bash
kubectl rollout restart deployment nginx-static -n nginx-static
```

### Step 2: Add Service IP to /etc/hosts
Retrieve the ClusterIP of the `nginx-static` service:
```bash
kubectl get svc nginx-static -n nginx-static
```
Note the `CLUSTER-IP` value (for example, `10.96.55.123`).

Next, map this IP to the required domain name on the node itself. Open the hosts file:
```bash
sudo vi /etc/hosts
```
Add the following line to the bottom of the file (replace with your actual ClusterIP):
```text
10.96.55.123    ITKiddie.k8s.local
```
Save and exit.

### Step 3: Verification
Run the `curl` commands provided in the prompt to ensure the Nginx server rejects older TLS versions.

1. **Test TLSv1.2:** This should **fail** with a handshake error (e.g., `alert protocol version`).
   ```bash
   curl --tls-max 1.2 https://ITKiddie.k8s.local -k
   ```

2. **Test TLSv1.3:** This should **succeed** and return the default Nginx HTML page.
   ```bash
   curl --tlsv1.3 https://ITKiddie.k8s.local -k
   ```
