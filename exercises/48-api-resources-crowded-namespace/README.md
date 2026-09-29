# Exercise 48 — API Resource Enumeration & Role-Crowded Namespace Discovery

> Related: [README — Cluster Architecture](../../README.md#domain-1--cluster-architecture-25) | **Updated May 2026**

Filter namespaced API resources and programmatically determine the namespace with the maximum number of Role definitions.

## Tasks

1. Write names of all namespaced Kubernetes resources into `/course/16/resources.txt`.
2. Find the `project-*` Namespace with the highest number of Roles defined in it and write its name and amount of Roles into `/course/16/crowded-namespace.txt`.

<details>
<summary>Solution</summary>

```bash
mkdir -p /course/16

# 1. Namespaced resources list
kubectl api-resources --namespaced=true -o name > /course/16/resources.txt

# 2. Find crowded namespace by Role count
for ns in $(kubectl get ns -o name | grep 'project-'); do
  ns_name=${ns#namespace/}
  count=$(kubectl get roles -n $ns_name --no-headers 2>/dev/null | wc -l)
  echo "$count $ns_name"
done | sort -nr | head -n 1 > /course/16/crowded-namespace.txt
```

</details>
