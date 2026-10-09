# Question 12: PersistentVolumeClaim (PVC)

## Context
> *A Persistent Volume already exists and is retained for reuse.*
> 
> *Create a PersistentVolumeClaim named `MariaDB` in the `mariadb` namespace as follows:*
> 1. *Access mode `ReadWriteOnce`*
> 2. *Storage capacity `250Mi`*
> 
> *Edit the `maria-deployment` in the file located at `maria_deploy.yaml` to use the newly created PVC.*
> 
> *Verify that the deployment is running and is stable.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up the namespace, the existing PersistentVolume, and generate the `maria_deploy.yaml` file you need to modify.

```bash
kubectl create namespace mariadb

# Create an existing Persistent Volume
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
spec:
  capacity:
    storage: 500Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/tmp/data"
EOF

# Create the starter deployment file
cat << 'EOF' > maria_deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: maria-deployment
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.5
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "secret"
        # YOU NEED TO ADD VOLUME MOUNTS HERE
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This task tests your ability to manually create a PersistentVolumeClaim from scratch and attach it to an existing deployment manifest.

### Step 1: Create the PVC
You must create the PVC manifest manually, as there is no imperative command for generating PVCs in Kubernetes. Create a file named `pvc.yaml`.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: MariaDB
  namespace: mariadb
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
```

Apply the PVC to the cluster:
```bash
kubectl apply -f pvc.yaml
```

Verify that the PVC successfully bounds to the existing PV (Status should be `Bound`):
```bash
kubectl get pvc MariaDB -n mariadb
```

### Step 2: Edit the Deployment File
Open the provided `maria_deploy.yaml` file in your text editor.
You need to add two blocks:
1. `volumeMounts` inside the container definition (MariaDB typically mounts to `/var/lib/mysql`).
2. `volumes` at the pod spec level, referencing the PVC name.

Modify the file to look like this:

```yaml
    spec:
      containers:
      - name: mariadb
        image: mariadb:10.5
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "secret"
        volumeMounts:               # ADD THIS
        - name: data-volume         # ADD THIS
          mountPath: /var/lib/mysql # ADD THIS
      volumes:                      # ADD THIS
      - name: data-volume           # ADD THIS
        persistentVolumeClaim:      # ADD THIS
          claimName: MariaDB        # ADD THIS
```

### Step 3: Apply and Verify
Apply the modified deployment file to the cluster:
```bash
kubectl apply -f maria_deploy.yaml
```

Verify that the deployment spins up the pod successfully and that it remains stable (Status `Running`, Ready `1/1`):
```bash
kubectl get pods -n mariadb -w
```
