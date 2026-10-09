# Question 10: Horizontal Pod Autoscaler (HPA)

## Context
> *Create a new HorizontalPodAutoScaler [HPA] named `apache-server` in the `autoscale` namespace.*
> 
> *Tasks:*
> 1. *This HPA must target the existing deployment called `apache-deployment` in the `autoscale` namespace.*
> 2. *Set the HPA to target for 50% CPU usage per Pod.*
> 3. *Configure the HPA to have a minimum of 1 pod and maximum of 4 pods. Also, we have to set the downscale stabilization window to 30 seconds.*

---

## 🛠️ Playground Setup
Run this block to set up the namespace and the dummy deployment. *(Note: For an HPA to function, the target pods **must** have CPU requests defined, which we set here).*

```bash
kubectl create namespace autoscale

kubectl create deployment apache-deployment --image=httpd -n autoscale
kubectl set resources deployment apache-deployment -n autoscale --requests=cpu=100m
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This task requires creating an HPA and configuring a custom scaling behavior. The easiest way to tackle this is to generate a base YAML using the imperative command and then edit it to add the advanced `behavior` block.

### Step 1: Generate the Base HPA YAML
Use the `kubectl autoscale` command to generate the foundation of the HPA resource and save it to a file.

```bash
kubectl autoscale deployment apache-deployment \
  --name=apache-server \
  --cpu-percent=50 \
  --min=1 \
  --max=4 \
  --namespace=autoscale \
  --dry-run=client -o yaml > hpa.yaml
```

### Step 2: Edit the YAML to Add Stabilization Window
Open `hpa.yaml` in `vi` or `nano`. 
Ensure the `apiVersion` is `autoscaling/v2` (the standard for newer Kubernetes clusters that support advanced behaviors), and add the `behavior` block under `spec`.

Modify your file to look like this:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: apache-server
  namespace: autoscale
spec:
  maxReplicas: 4
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: apache-deployment
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
  # --- ADD THIS BLOCK ---
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
  # ----------------------
```

### Step 3: Apply the Configuration
Create the HPA from the modified file:
```bash
kubectl apply -f hpa.yaml
```

### Step 4: Verification
Check that the HPA was created and is targeting the correct deployment.
```bash
kubectl get hpa apache-server -n autoscale
```
*(Note: The `TARGETS` column might show `<unknown>/50%` initially until the metrics-server collects the data, but this is normal).*

Verify the custom behavior was applied by describing the HPA:
```bash
kubectl describe hpa apache-server -n autoscale | grep -i "Behavior" -A 5
```
You should see `ScaleDown:` with a `Stabilization Window: 30` listed.
