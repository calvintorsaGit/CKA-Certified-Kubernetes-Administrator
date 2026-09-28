# Exercise 32 — Argo CD Installation via Helm

> **Hard** | ~20 min | Domain: Cluster Architecture (25%)
>
> Related: [README — Cluster Architecture](../../README.md#domain-4--cluster-architecture-installation--configuration-25)

Install Argo CD using its official Helm chart, customize the installation using a `values.yaml` file, and verify its components are running correctly.

## Tasks

1. Add the official Argo CD Helm repository (`https://argoproj.github.io/argo-helm`)
2. Create a namespace called `argocd`
3. Create a `values.yaml` file that disables the `dex` component (set `dex.enabled: false`)
4. Install Argo CD using Helm into the `argocd` namespace:
   - Release name: `argocd`
   - Chart version: `7.3.11`
   - Use the `values.yaml` created in step 3
5. Verify that all Argo CD pods are running and that no `dex` pod is deployed.
6. Retrieve the initial admin password from the generated Secret.

## Hints

<details>
<summary>Stuck? Click to reveal hints</summary>

- `helm repo add argo https://argoproj.github.io/argo-helm`
- `helm install <release-name> <chart-name> -n <namespace> --version <version> -f <values-file>`
- Check the Argo CD documentation for default secret names. The initial password is in a secret named `argocd-initial-admin-secret`.

</details>

## What tripped me up

> The Argo CD helm chart installs many components by default, including `dex` for SSO. In restricted environments, or to save resources on a local test cluster, disabling it via `values.yaml` is a common task. I forgot that I needed to pass the `-f` flag for the values to apply, which resulted in a heavier installation than intended.

## Verify

```bash
# Verify pods in the namespace
k get pods -n argocd

# Ensure no dex pod exists
k get pods -n argocd | grep dex
# Should return nothing

# Verify the secret exists
k get secret argocd-initial-admin-secret -n argocd
```

## Cleanup

```bash
helm uninstall argocd -n argocd
k delete ns argocd
rm values.yaml
```

<details>
<summary>Solution</summary>

```bash
# 1. Add repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 2. Create namespace
k create namespace argocd

# 3. Create values.yaml
cat <<EOF > values.yaml
dex:
  enabled: false
EOF

# 4. Install Argo CD
helm install argocd argo/argo-cd -n argocd --version 7.3.11 -f values.yaml

# 5. Verify pods
k get pods -n argocd
# You should see argocd-server, argocd-repo-server, argocd-application-controller, etc., but no dex pod.

# 6. Get admin password
k -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

References:
- Helm Docs: https://helm.sh/docs/
- Argo CD Helm Chart: https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd

</details>
