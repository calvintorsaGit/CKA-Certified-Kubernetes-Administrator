#!/bin/bash
# setup-mock-exam-01.sh
# Creates the necessary resources to take Mock Exam 01

echo "Setting up Mock Exam 01 environment..."

# 1. Namespaces
kubectl create namespace production --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace staging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace databases --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace shop --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace test --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace restricted --dry-run=client -o yaml | kubectl apply -f -

# 2. Q1: Pod Deployment Troubleshooting
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: app-frontend
  namespace: production
spec:
  containers:
  - name: app
    image: busybox:1.36
    command: ["/bin/sh", "-c"]
    args: ["cat /etc/app/config.yaml && sleep 3600 || exit 1"]
EOF

# 3. Q4: Persistent Volume Configuration
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db-app
  namespace: databases
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db-app
  template:
    metadata:
      labels:
        app: db-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
EOF

# 4. Q5: Network Policy Troubleshooting
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: shop-frontend
  namespace: shop
  labels:
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:1.25
---
apiVersion: v1
kind: Pod
metadata:
  name: shop-backend
  namespace: shop
  labels:
    tier: backend
spec:
  containers:
  - name: nginx
    image: nginx:1.25
---
apiVersion: v1
kind: Pod
metadata:
  name: shop-database
  namespace: shop
  labels:
    tier: database
spec:
  containers:
  - name: nginx
    image: nginx:1.25
EOF

# 5. Q6: Helm Chart
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
mkdir -p "$REPO_ROOT/helm-charts/monitoring/templates"
cat <<EOF > "$REPO_ROOT/helm-charts/monitoring/Chart.yaml"
apiVersion: v2
name: monitoring
description: A Helm chart for monitoring
type: application
version: 0.1.0
appVersion: "1.16.0"
EOF

cat <<EOF > "$REPO_ROOT/helm-charts/monitoring/values.yaml"
replica_count: 1
storage_size: 10Gi
persistence: false
EOF

cat <<EOF > "$REPO_ROOT/helm-charts/monitoring/templates/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-stack
spec:
  replicas: {{ .Values.replica_count }}
  selector:
    matchLabels:
      app: monitoring
  template:
    metadata:
      labels:
        app: monitoring
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
EOF

# 6. Q9: HPA and Application Scaling
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        resources:
          requests:
            cpu: 100m
          limits:
            cpu: 200m
EOF

# 7. Q10: Ingress Configuration with TLS
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: default
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: api
EOF
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: api-tls-cert
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: ZHVtbXkK
  tls.key: ZHVtbXkK
EOF

echo "Mock Exam 01 setup complete."
