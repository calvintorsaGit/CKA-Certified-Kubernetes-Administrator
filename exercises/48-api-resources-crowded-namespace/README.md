# Exercise 48 — API Resource Enumeration & Role-Crowded Namespace Discovery

> Related: [README — Cluster Architecture](../../README.md#domain-1--cluster-architecture-25) | **Updated May 2026**

Filter namespaced API resources and programmatically determine the namespace with the maximum number of Role definitions.

## Setup Environment

Run this script to set up sample project namespaces and roles:

```bash
sudo mkdir -p /course/16

# Create test project namespaces
kubectl create ns project-alpha
kubectl create ns project-beta
kubectl create ns project-gamma

# Populate Roles in project-alpha (2 roles)
kubectl create role role-a1 --verb=get --resource=pods -n project-alpha
kubectl create role role-a2 --verb=get --resource=services -n project-alpha

# Populate Roles in project-beta (4 roles - winner)
kubectl create role role-b1 --verb=get --resource=pods -n project-beta
kubectl create role role-b2 --verb=get --resource=services -n project-beta
kubectl create role role-b3 --verb=get --resource=configmaps -n project-beta
kubectl create role role-b4 --verb=get --resource=secrets -n project-beta

# Populate Roles in project-gamma (1 role)
kubectl create role role-g1 --verb=get --resource=pods -n project-gamma
```

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
