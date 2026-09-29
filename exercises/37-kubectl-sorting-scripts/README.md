# Exercise 37 — kubectl Sorting Bash Scripts

> Related: [README — Troubleshooting](../../README.md#domain-7--troubleshooting-30) | **Updated May 2026**

Create automated shell scripts using `kubectl --sort-by` to sort cluster resources by creation timestamp and UID.

## Tasks

Create two bash script files:

1. Write a command into `/course/5/find_pods.sh` which lists all Pods in all Namespaces sorted by AGE (`metadata.creationTimestamp`).
2. Write a command into `/course/5/find_pods_uid.sh` which lists all Pods in all Namespaces sorted by `metadata.uid`.

<details>
<summary>Solution</summary>

```bash
mkdir -p /course/5

# 1. Creation timestamp sorting
cat <<'EOF' > /course/5/find_pods.sh
#!/bin/bash
kubectl get pods -A --sort-by=.metadata.creationTimestamp
EOF
chmod +x /course/5/find_pods.sh

# 2. UID sorting
cat <<'EOF' > /course/5/find_pods_uid.sh
#!/bin/bash
kubectl get pods -A --sort-by=.metadata.uid
EOF
chmod +x /course/5/find_pods_uid.sh
```

</details>
