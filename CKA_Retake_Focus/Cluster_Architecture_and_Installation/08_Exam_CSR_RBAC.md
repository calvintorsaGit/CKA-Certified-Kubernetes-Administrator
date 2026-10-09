# Exam 08: CSR and RBAC for a New User

**Domain:** Cluster Architecture, Installation & Configuration (25%)

## Context
You have a new team member, John, who needs access to the Kubernetes cluster.

## Your Task
1. Create a new user called `john`. Grant him access to the cluster using a CertificateSigningRequest (CSR) named `john-developer`. The CSR must be approved.
2. The private key exists in the location: `/root/CKA/john.key` and the CSR file exists at `/root/CKA/john.csr`. *(Important Note: As of Kubernetes 1.19, the CertificateSigningRequest object expects a `signerName`.)*
3. Create a Role named `developer` in the `development` namespace. This role should grant permission to `create`, `list`, `get`, `update` and `delete` pods.
4. Bind this Role to the user `john` so he has the appropriate permissions in the `development` namespace.

---

## 🛠️ Playground Setup
Run this block in your playground control plane terminal to generate the key and CSR so you can practice the task. (In the real exam, these files will already be placed there for you).

```bash
mkdir -p /root/CKA
# Generate the private key
openssl genrsa -out /root/CKA/john.key 2048
# Generate the CSR (the Subject /CN maps to the user)
openssl req -new -key /root/CKA/john.key -subj "/CN=john/O=developer" -out /root/CKA/john.csr
# Create the target namespace
kubectl create namespace development
```

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

Here is exactly how you should think about and solve this in the exam.
*Pro-tip: You can use the official Kubernetes documentation to grab the CSR template! Search the docs for "Certificate Signing Requests".*

### Step 1: Create the CertificateSigningRequest Object
Since you are given the `.csr` file, you need to base64 encode its contents and place it into a Kubernetes `CertificateSigningRequest` manifest.

1. Get the base64 encoded CSR:
   ```bash
   cat /root/CKA/john.csr | base64 | tr -d "\n"
   ```

2. Create a file named `john-csr.yaml` using the template from the official docs:
   ```yaml
   apiVersion: certificates.k8s.io/v1
   kind: CertificateSigningRequest
   metadata:
     name: john-developer
   spec:
     request: <paste-base64-encoded-csr-here>
     signerName: kubernetes.io/kube-apiserver-client
     usages:
     - client auth
   ```

3. Apply it:
   ```bash
   kubectl apply -f john-csr.yaml
   ```

### Step 2: Approve the CSR
Check the status of the CSR, then approve it:
```bash
kubectl get csr
kubectl certificate approve john-developer
```

Verify that the status is now `Approved,Issued`:
```bash
kubectl get csr john-developer
```

### Step 3: Create the Role
Use imperative commands to create the role quickly:
```bash
kubectl create role developer \
  --verb=create,list,get,update,delete \
  --resource=pods \
  -n development
```

### Step 4: Create the RoleBinding
Bind the role `developer` to the user `john` in the `development` namespace:
```bash
kubectl create rolebinding developer-binding \
  --role=developer \
  --user=john \
  -n development
```

### Step 5: Verification
Always test the access in the exam using `auth can-i` to guarantee you got the points.

1. Check if `john` can list pods in `development`:
   ```bash
   kubectl auth can-i list pods --as=john -n development
   # Should return: yes
   ```
2. Check if `john` can delete pods in `development`:
   ```bash
   kubectl auth can-i delete pods --as=john -n development
   # Should return: yes
   ```
3. Check if `john` can list pods in `default`:
   ```bash
   kubectl auth can-i list pods --as=john -n default
   # Should return: no
   ```
