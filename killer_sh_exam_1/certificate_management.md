# Certificate Management with kubeadm

## Task Description
Solve this question on: `ssh cka9412`

Perform some tasks on cluster certificates:
1. Check how long the kube-apiserver server certificate is valid using openssl or cfssl.
2. Write the expiration date into `/course/14/expiration`.
3. Run the kubeadm command to list the expiration dates and confirm both methods show the same one.
4. Write the kubeadm command that would renew the kube-apiserver certificate into `/course/14/kubeadm-renew-certs.sh`.

---

## Solution Guide

### 1. SSH into the specified node
First, ensure you are on the correct node:
```bash
ssh cka9412
```

### 2. Check the certificate expiration using openssl
The API server certificate is typically located at `/etc/kubernetes/pki/apiserver.crt`. You can check its expiration date using the following `openssl` command:
```bash
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate
```

### 3. Write the expiration date to the required file
Copy the output date from the previous command (e.g., `May 15 12:00:00 2025 GMT`) or write the direct command output into the file. Make sure the directory exists:
```bash
mkdir -p /course/14
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate > /course/14/expiration
```

### 4. Confirm with kubeadm
Use `kubeadm` to list the expiration dates of all certificates and verify it matches the openssl output:
```bash
kubeadm certs check-expiration
```
*Note: In older versions of Kubernetes, the command might be `kubeadm alpha certs check-expiration`.*

### 5. Write the command to renew the certificate
The command to renew specifically the kube-apiserver certificate is `kubeadm certs renew apiserver`. Write this command into the specified shell script file:
```bash
echo "kubeadm certs renew apiserver" > /course/14/kubeadm-renew-certs.sh
```

Make the script executable (optional, but good practice):
```bash
chmod +x /course/14/kubeadm-renew-certs.sh
```

### 6. Return to your main terminal
After completing the tasks, don't forget to exit the node:
```bash
exit
```
