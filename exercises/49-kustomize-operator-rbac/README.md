# Exercise 49 — Kustomize Base Configuration & CRD Operator RBAC Patching

> Related: [README — Cluster Architecture](../../README.md#domain-1--cluster-architecture-25) | **Updated May 2026**

Fix missing RBAC permissions in a Kustomize operator base, add custom resources, and deploy overlay manifests to production.

## Tasks

1. Inspect operator pod logs to identify missing CRD permissions.
2. Update `Role` permissions (`operator-role`) in Kustomize base config at `/course/17/operator/base`.
3. Add a new Student resource `student4` in base configuration.
4. Build and deploy Kustomize configuration to production overlay:
   `kubectl kustomize /course/17/operator/prod | kubectl apply -f -`

<details>
<summary>Solution</summary>

```bash
# 1. Inspect logs
kubectl logs -n operator-system deployment/operator

# 2. Add CRD verbs to Role in /course/17/operator/base/role.yaml
# Ensure apiGroups, resources, and verbs: ["get", "list", "watch"] are correct.

# 3. Add student4 manifest to /course/17/operator/base/student4.yaml and list under resources in kustomization.yaml

# 4. Deploy prod overlay
kubectl kustomize /course/17/operator/prod | kubectl apply -f -
```

</details>
