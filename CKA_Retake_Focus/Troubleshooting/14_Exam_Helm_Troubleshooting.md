# Exam 14: Helm Troubleshooting and Uninstallation

**Domain:** Troubleshooting (30%) / Workloads & Scheduling

## Context
Helm is the package manager for Kubernetes. In the exam, you might be asked to find a specific application or image deployed by Helm and remove it.

## Your Task
On the cluster, the team has installed multiple helm charts across different namespaces. By mistake, those deployed resources include a vulnerable image called `kodekloud/webapp-color:v1`. 

1. Find out the release name of the Helm chart that deployed this image.
2. Uninstall that specific Helm release.

Validation checks to keep in mind:
* Is the helm release uninstalled?

---

## 🛠️ Playground Setup
Run this block to set up a dummy scenario where multiple Helm releases are deployed, one of which contains the vulnerable image.

```bash
# Create namespaces
kubectl create namespace alpha
kubectl create namespace beta

# We'll simulate Helm releases by creating secrets that Helm uses to track releases, 
# and the corresponding Deployments. (In a real environment, you'd use `helm install`, 
# but this script mimics the end-state perfectly without needing a Helm chart repository).

# 1. A safe release in namespace 'alpha'
helm create safe-app
helm install safe-release ./safe-app -n alpha

# 2. The vulnerable release in namespace 'beta'
helm create vulnerable-app
# Modify the deployment template to use the vulnerable image
sed -i 's/repository: nginx/repository: kodekloud\/webapp-color/g' vulnerable-app/values.yaml
sed -i 's/tag: ""/tag: "v1"/g' vulnerable-app/values.yaml
helm install legacy-web ./vulnerable-app -n beta

# Clean up local chart folders
rm -rf safe-app vulnerable-app
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Find the Vulnerable Pod and Namespace
The fastest way to figure out which namespace has the vulnerable image is to list all pods across all namespaces and display their images.

```bash
# Get all pods with their namespaces and images, and grep for the vulnerable one
kubectl get pods -A -o custom-columns=NAMESPACE:.metadata.namespace,POD:.metadata.name,IMAGE:.spec.containers[*].image | grep kodekloud/webapp-color:v1
```
*Example Output:*
```text
beta      legacy-web-7b98d4f...    kodekloud/webapp-color:v1
```
Now you know the namespace is `beta`.

### Step 2: Find the Helm Release Name
Now that we know the pod and the namespace, we need to find the Helm release name. Helm standardizes label names, so we can check the pod's labels.

```bash
# Look at the labels for pods in the 'beta' namespace
kubectl get pods -n beta --show-labels
```

You will see a label called `app.kubernetes.io/instance=legacy-web` or `release=legacy-web`. **The instance/release label is the Helm release name.** 

*Alternative pure-Helm approach:*
You can also just list all Helm releases in all namespaces:
```bash
helm list -A
```
If there are only a few, you can inspect their manifests to find the image:
```bash
helm get manifest legacy-web -n beta | grep webapp-color
```

### Step 3: Uninstall the Helm Release
Once you have the release name (`legacy-web`) and the namespace (`beta`), use the `helm uninstall` command to completely remove the release and all its resources.

```bash
helm uninstall legacy-web -n beta
```

### Step 4: Verification
Verify that the release was successfully uninstalled and the pods are terminating/gone:

```bash
# Check helm releases
helm list -n beta

# Check if the vulnerable pod is gone
kubectl get pods -n beta
```

If the release is no longer listed, you have successfully completed the task!
