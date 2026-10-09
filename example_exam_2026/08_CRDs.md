# Question 08: Custom Resource Definitions (CRDs)

## Context
> *Task:*
> 1. *Create a list of all cert-manager [CRDs] and save it to `~/resources.yaml`. Make sure `kubectl` uses the default output format and use `kubectl` to list CRDs.*
> 2. *Using `kubectl`, extract the documentation for the `subject` specification field of the `Certificate` Custom Resource and save it to `~/subject.yaml`. You may use any output format that `kubectl` supports.*

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to install the real `cert-manager` manifests, which will deploy the necessary CRDs to your cluster so you can practice exploring them.

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This question tests your ability to query Custom Resource Definitions and, most importantly, your knowledge of how to use `kubectl explain` to explore the schema of third-party resources.

### Step 1: List the cert-manager CRDs
The prompt explicitly states: "Make sure kubectl uses default output format". The default output format for `kubectl get` is the standard tabular view, *not* YAML—even though they ask you to save it to a file named `resources.yaml`. This is a classic exam trick to see if you follow the text instructions over the file extension implications.

```bash
kubectl get crds | grep cert-manager > ~/resources.yaml
```

### Step 2: Extract Documentation via `kubectl explain`
Just like native Kubernetes resources (e.g., Pods, Deployments), properly configured CRDs provide documentation directly to the cluster. You can read this documentation using `kubectl explain`. 

To drill down into the `subject` field within the `spec` of a `Certificate` resource:

```bash
kubectl explain certificate.spec.subject > ~/subject.yaml
```

### Step 3: Verification
Double-check your work to ensure the files contain the expected output.

1. **Check the CRD list:**
   ```bash
   cat ~/resources.yaml
   ```
   *You should see a tabular list of CRDs like `certificates.cert-manager.io`, `clusterissuers.cert-manager.io`, etc.*

2. **Check the explain output:**
   ```bash
   cat ~/subject.yaml
   ```
   *You should see the hierarchical documentation describing the `subject` field's expected types and description.*
