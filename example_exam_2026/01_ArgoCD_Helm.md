# Question 1: Helm and Argo CD

## Context
> *Install Argo CD in a Kubernetes cluster using Helm while ensuring that CRDs are not installed (as they are pre-installed). Follow the steps below:*

## Requirements
1. Add the official Argo CD Helm repository (`https://argoproj.github.io/argo-helm`) with the name `argo`.
2. Generate a Helm template from the Argo CD chart version `7.7.3` for the `argocd` namespace.
3. Ensure that CRDs are not installed by configuring the chart accordingly.
4. Save the generated YAML manifest to `/home/argo/argo-helm.yaml`.

---

## ✅ Solution & Discussion

Here are the steps to fulfill the requirements.

### Step 1: Add the Argo CD Helm Repository
You need to add the official repository so Helm can fetch the chart.

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### Step 2 & 3: Generate the Helm Template and Disable CRDs
The requirement states to "configure the chart accordingly" to skip CRDs and generate the template for the `argocd` namespace.

```bash
helm template argocd argo/argo-cd \
  --version 7.7.3 \
  --namespace argocd \
  --set crds.install=false \
  > /home/argo/argo-helm.yaml
```
*(Note: Depending on the specific chart version's values, disabling CRDs is usually done via `--set crds.install=false` or `--set crds.keep=false`. Additionally, `helm template` in Helm 3 naturally skips rendering the `crds/` directory unless `--include-crds` is specified, but setting the value explicitly fulfills "configuring the chart accordingly".)*

### Step 4: Verify the Output
You can verify the file was created correctly:

```bash
cat /home/argo/argo-helm.yaml | grep -i kind:
```
Check that there are no `CustomResourceDefinition` kinds in the generated YAML.

### Step 5: Install Argo CD (Optional/If Required)
If the task requires actually installing it into the cluster, you can apply the generated template:
```bash
kubectl create namespace argocd
kubectl apply -f /home/argo/argo-helm.yaml
```
Alternatively, if you were meant to use Helm to install it directly rather than just templating it:
```bash
helm install argocd argo/argo-cd \
  --version 7.7.3 \
  --namespace argocd --create-namespace \
  --set crds.install=false
```
