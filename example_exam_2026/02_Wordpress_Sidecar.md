# Question 02: Deployment Sidecar

## Context
> *Update the existing deployment `wordpress`, adding a sidecar container named `sidecar` using the `busybox:stable` image to the existing pod.*
> 
> *The new sidecar container has to run the following command: `/bin/sh -c "tail -f /var/log/wordpress.log"` use a volume mounted at `/var/log` to make the log file `wordpress.log` available to the co-located container.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up a mock `wordpress` deployment that continuously writes logs. This gives you a starting point to test adding the sidecar and shared volume.

```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - name: wordpress
        image: busybox
        command: ["/bin/sh", "-c", "mkdir -p /var/log && while true; do echo \"[\$(date)] Mock wordpress log entry\" >> /var/log/wordpress.log; sleep 2; done"]
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

To solve this, you need to modify the existing deployment to inject a sidecar container that shares a volume with the main container to read its logs.

### Step 1: Edit the Deployment
Open the deployment manifest in your default editor:

```bash
kubectl edit deployment wordpress
```

### Step 2: Add the Sidecar Container and Volumes
You will need to make three modifications to the pod template (`spec.template.spec`):

1. **Add the Sidecar Container:** Under the `containers:` list, add the new `sidecar` container with the specified command and volume mount.
2. **Mount Volume to Main Container:** Ensure the main `wordpress` container also has the same volume mounted to `/var/log` (or wherever it's writing logs, assuming `/var/log` based on the prompt).
3. **Define the Volume:** Under `volumes:`, define an `emptyDir` volume to act as the shared storage between the two containers.

Here is what the modified sections should look like:

```yaml
spec:
  template:
    spec:
      containers:
      # --- Existing Container ---
      - name: wordpress
        image: wordpress:latest # (example existing image)
        volumeMounts:
        - name: shared-logs
          mountPath: /var/log

      # --- New Sidecar Container ---
      - name: sidecar
        image: busybox:stable
        command: ["/bin/sh", "-c", "tail -f /var/log/wordpress.log"]
        volumeMounts:
        - name: shared-logs
          mountPath: /var/log
          
      # --- Shared Volume Definition ---
      volumes:
      - name: shared-logs
        emptyDir: {}
```

### Step 3: Verify the Changes
Save and exit the editor. Kubernetes will automatically roll out the new version of the pods. Verify that the pods are running and have 2/2 containers ready:

```bash
kubectl get pods -l app=wordpress
```

You can also check the logs of the sidecar container specifically to ensure it is tailing the file properly:

```bash
kubectl logs deploy/wordpress -c sidecar
```
