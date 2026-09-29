# Exercise 44 — Schedule Pod Exclusively on Control Plane Nodes

> Related: [README — Workloads & Scheduling](../../README.md#domain-1--workloads--scheduling-15) | **Updated May 2026**

Configure node selectors and tolerations to force a Pod onto control plane nodes without adding new node labels.

## Tasks

1. Create a Pod of image `httpd:2-alpine` in Namespace `default`.
2. Pod name: `pod1`, Container name: `pod1-container`.
3. Force schedule strictly on control plane nodes.
4. Do NOT add new labels to any nodes.

<details>
<summary>Solution</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
  namespace: default
spec:
  containers:
  - name: pod1-container
    image: httpd:2-alpine
  nodeSelector:
    node-role.kubernetes.io/control-plane: ""
  tolerations:
  - key: node-role.kubernetes.io/control-plane
    operator: Exists
    effect: NoSchedule
```

</details>
