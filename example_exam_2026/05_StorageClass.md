# Question 05: Default StorageClass

## Context
> *Create a new `StorageClass` named `local-kiddie` with the provisioner `rancher.io/local-path`.*
> 
> *Set the `volumeBindingMode` to `WaitForFirstConsumer`.*
> 
> *Configure the `StorageClass` as the default `StorageClass`.*
> 
> *Do not modify any existing Deployments or PersistentVolumeClaims.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to set up a dummy "existing" default StorageClass. This simulates a real cluster environment where you must remove the default status from the old class before assigning it to the new one.

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: Immediate
EOF
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This question tests your knowledge of creating StorageClasses and managing the default StorageClass annotation in a cluster. 

### Step 1: Remove Existing Default (Crucial Exam Step)
Before setting a new default StorageClass, you should check if one already exists. Having two default StorageClasses can cause PVC provisioning to fail.

1. Check existing StorageClasses:
   ```bash
   kubectl get sc
   ```
2. If another class (e.g., `standard`) has `(default)` next to its name, remove its default annotation:
   ```bash
   kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
   ```

### Step 2: Create the New StorageClass
Create a manifest file for the new StorageClass. You can look up the structure in the Kubernetes documentation under "Storage Classes".

Create `sc.yaml`:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-kiddie
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
```

### Step 3: Apply and Verify
Apply the manifest to the cluster:

```bash
kubectl apply -f sc.yaml
```

Verify that the new StorageClass is created and is marked as the only default:

```bash
kubectl get sc
```
*Expected Output:*
```text
NAME                     PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-kiddie (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  10s
standard                 kubernetes.io/...       Delete          Immediate              false                  5m
```
