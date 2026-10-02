# Exercise 34 — CoreDNS and FQDN Configurations

> Related: [README — Services & Networking](../../README.md#domain-4--services--networking-20) | **Updated May 2026**

The Deployment controller in Namespace `lima-control` communicates with various cluster-internal endpoints by using their DNS FQDN values.

## Tasks

Update the ConfigMap used by the Deployment with the correct FQDN values for:

1. `DNS_1`: Service `kubernetes` in Namespace `default`
2. `DNS_2`: Headless Service `department` in Namespace `lima-workload`
3. `DNS_3`: Pod `section100` in Namespace `lima-workload`. It should work even if the Pod IP changes
4. `DNS_4`: A Pod with IP `1.2.3.4` in Namespace `kube-system`

Ensure the Deployment works with the updated values.

## Setup Environment

Run this script to set up the namespaces, services, and the configmap/deployment:

```bash
# Clean up previous attempts
kubectl delete ns lima-control lima-workload --ignore-not-found

# Create Namespaces
kubectl create ns lima-control
kubectl create ns lima-workload

# Setup for DNS_2 and DNS_3 (Headless service and pod)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: department
  namespace: lima-workload
spec:
  clusterIP: None
  selector:
    app: department
---
apiVersion: v1
kind: Pod
metadata:
  name: section100
  namespace: lima-workload
  labels:
    app: department
spec:
  # Required to bind the pod to the headless service DNS
  hostname: section100
  subdomain: department
  containers:
  - name: nginx
    image: nginx:alpine
EOF

# Create ConfigMap and Deployment for lima-control
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: fqdn-config
  namespace: lima-control
data:
  DNS_1: "TODO"
  DNS_2: "TODO"
  DNS_3: "TODO"
  DNS_4: "TODO"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dns-tester
  namespace: lima-control
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dns-tester
  template:
    metadata:
      labels:
        app: dns-tester
    spec:
      containers:
      - name: tester
        image: busybox:1.36
        command: ["sh", "-c", "env | grep DNS_; sleep 3600"]
        envFrom:
        - configMapRef:
            name: fqdn-config
EOF
```

<details>
<summary>Solution & Explanation</summary>

### How Kubernetes DNS Works

Kubernetes CoreDNS creates DNS records for Services and Pods using specific formats. Understanding these formats is key to solving this exercise:

1. **Normal Services (`DNS_1`)**
   - **Format:** `<service-name>.<namespace>.svc.cluster.local`
   - **Answer:** `kubernetes.default.svc.cluster.local`

2. **Headless Services (`DNS_2`)**
   - Headless services (`clusterIP: None`) use the exact same format as normal services.
   - **Format:** `<service-name>.<namespace>.svc.cluster.local`
   - **Answer:** `department.lima-workload.svc.cluster.local`

3. **Pods behind a Headless Service (`DNS_3`)**
   - If a Pod is bound to a headless service (using `hostname` and `subdomain` fields in its spec), it gets its own stable DNS record. This is what the question means by "works even if the Pod IP changes."
   - **Format:** `<pod-name>.<headless-service-name>.<namespace>.svc.cluster.local`
   - **Answer:** `section100.department.lima-workload.svc.cluster.local`

4. **Direct Pod IPs (`DNS_4`)**
   - You can resolve any pod directly by its IP address, but you must replace the dots (`.`) with dashes (`-`).
   - **Format:** `<ip-with-dashes>.<namespace>.pod.cluster.local`
   - **Answer:** `1-2-3-4.kube-system.pod.cluster.local`

### Commands to Solve

```bash
# 1. Edit the ConfigMap
kubectl edit configmap fqdn-config -n lima-control

# 2. Update the values under 'data':
data:
  DNS_1: kubernetes.default.svc.cluster.local
  DNS_2: department.lima-workload.svc.cluster.local
  DNS_3: section100.department.lima-workload.svc.cluster.local
  DNS_4: 1-2-3-4.kube-system.pod.cluster.local

# 3. Rollout restart the deployment so it picks up the new ConfigMap environment variables
kubectl rollout restart deployment dns-tester -n lima-control

# 4. Verify the new environment variables are loaded
kubectl logs -n lima-control deployment/dns-tester
```

</details>
