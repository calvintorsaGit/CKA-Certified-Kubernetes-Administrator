# Exercise 49 — Kustomize Base Configuration & CRD Operator RBAC Patching

> Related: [README — Cluster Architecture](../../README.md#domain-1--cluster-architecture-25) | **Updated May 2026**

Fix missing RBAC permissions in a Kustomize operator base, add custom resources, and deploy overlay manifests to production.

## Setup Environment

Run this script to set up the `/course/17/operator` directory structure and initial broken deployment:

```bash
# Clean up any previous attempts
kubectl delete ns operator-system --ignore-not-found
kubectl delete crd students.stable.example.com --ignore-not-found
kubectl delete clusterrole operator-role --ignore-not-found
sudo rm -rf /course/17

# Create directories
sudo mkdir -p /course/17/operator/base /course/17/operator/prod

# Create namespace FIRST
kubectl create ns operator-system

# Create CRD and wait for it to be registered
kubectl apply -f - <<EOF
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: students.stable.example.com
spec:
  group: stable.example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                name: {type: string}
  scope: Namespaced
  names:
    plural: students
    singular: student
    kind: Student
EOF
kubectl wait --for=condition=Established crd/students.stable.example.com --timeout=15s

# Now create all the kustomize files on disk
sudo tee /course/17/operator/base/crd.yaml > /dev/null <<'EOF'
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: students.stable.example.com
spec:
  group: stable.example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                name: {type: string}
  scope: Namespaced
  names:
    plural: students
    singular: student
    kind: Student
EOF

sudo tee /course/17/operator/base/role.yaml > /dev/null <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: operator-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
EOF

sudo tee /course/17/operator/base/student1.yaml > /dev/null <<'EOF'
apiVersion: stable.example.com/v1
kind: Student
metadata:
  name: student1
  namespace: operator-system
spec:
  name: Alice
EOF

sudo tee /course/17/operator/base/deployment.yaml > /dev/null <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: operator
  namespace: operator-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: operator
  template:
    metadata:
      labels:
        app: operator
    spec:
      containers:
      - name: operator
        image: busybox:1.36
        command: ["sh", "-c", "while true; do echo '[ERROR] cannot list resource students in API group stable.example.com'; sleep 5; done"]
EOF

sudo tee /course/17/operator/base/kustomization.yaml > /dev/null <<'EOF'
resources:
- crd.yaml
- role.yaml
- student1.yaml
- deployment.yaml
EOF

sudo tee /course/17/operator/prod/kustomization.yaml > /dev/null <<'EOF'
resources:
- ../base
EOF

# Deploy everything
kubectl kustomize /course/17/operator/prod | kubectl apply -f -

# Verify
echo "--- Waiting for pod to start ---"
sleep 5
kubectl get pods -n operator-system
```

## Tasks

1. Inspect operator pod logs in `operator-system` namespace to identify missing CRD permissions.
2. Update `ClusterRole` permissions (`operator-role`) in Kustomize base config at `/course/17/operator/base/role.yaml`.
3. Add a new Student resource `student4` in base configuration (`/course/17/operator/base/student4.yaml` & update `kustomization.yaml`).
4. Build and deploy Kustomize configuration to production overlay in namespace `operator-system`:
   `kubectl kustomize /course/17/operator/prod | kubectl apply -f -`

## Key Learning

- CRDs must be **established** before custom resources that use them can be created
- Kustomize `resources:` list order matters — CRDs should come first
- `kubectl logs` reveals RBAC errors that tell you exactly which apiGroup/resource/verb is missing
- ClusterRole rules need `apiGroups`, `resources`, and `verbs` to match what the operator needs

## Hints

<details>
<summary>Stuck? Click to reveal hints</summary>

- Check operator logs: `kubectl logs -n operator-system deployment/operator`
- The error message tells you exactly which apiGroup and resource is missing from the ClusterRole
- Edit role: `sudo vi /course/17/operator/base/role.yaml`
- Add a rule for `apiGroups: ["stable.example.com"]`, `resources: ["students"]`, `verbs: ["get", "list", "watch"]`
- Create student4: copy `student1.yaml` → `student4.yaml`, change name and spec
- Don't forget to add `student4.yaml` to `kustomization.yaml` resources list

</details>

## Verify

```bash
# Check operator pod is running
kubectl get pods -n operator-system

# Check logs no longer show permission errors (after RBAC fix)
kubectl logs -n operator-system deployment/operator

# Check student4 was created
kubectl get students -n operator-system

# Check ClusterRole has correct permissions
kubectl describe clusterrole operator-role
```

## Cleanup

```bash
kubectl delete ns operator-system
kubectl delete crd students.stable.example.com
kubectl delete clusterrole operator-role
sudo rm -rf /course/17
```

<details>
<summary>Solution</summary>

```bash
# 1. Check logs to find missing permissions
kubectl logs -n operator-system deployment/operator
# Output: [ERROR] cannot list resource students in API group stable.example.com

# 2. Fix the ClusterRole — add stable.example.com/students permissions
sudo tee /course/17/operator/base/role.yaml > /dev/null <<'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: operator-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
- apiGroups: ["stable.example.com"]
  resources: ["students"]
  verbs: ["get", "list", "watch"]
EOF

# 3. Create student4 resource
sudo tee /course/17/operator/base/student4.yaml > /dev/null <<'EOF'
apiVersion: stable.example.com/v1
kind: Student
metadata:
  name: student4
  namespace: operator-system
spec:
  name: David
EOF

# 4. Update kustomization.yaml to include student4
sudo tee /course/17/operator/base/kustomization.yaml > /dev/null <<'EOF'
resources:
- crd.yaml
- role.yaml
- student1.yaml
- student4.yaml
- deployment.yaml
EOF

# 5. Deploy
kubectl kustomize /course/17/operator/prod | kubectl apply -f -

# 6. Verify
kubectl get students -n operator-system
kubectl describe clusterrole operator-role
```

</details>
