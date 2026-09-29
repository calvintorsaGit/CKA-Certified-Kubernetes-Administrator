# Exercise 35 — Kubelet TLS Bootstrapping & Certificate Inspection

> Related: [README — Security](../../README.md#domain-5--security-15) | **Updated May 2026**

Inspect TLS certificates used for Kubelet client authentication (outgoing) and Kubelet server authentication (incoming) on a worker node.

## Conventions

- **Primary Trap:** Confusing the client certificate (`kubelet-client-current.pem`) with the server certificate (`kubelet-server-current.pem`).
- **Validation Criteria:** Your answer is correct if:
  - Output file `/course/3/certificate-info.txt` contains Issuer and Extended Key Usage for both certificates.

## Tasks

Node `node1` has been added to the cluster using `kubeadm` and TLS bootstrapping.

Find the Issuer and Extended Key Usage values on `node1` for:
1. **Kubelet Client Certificate:** used for outgoing connections to the `kube-apiserver`
2. **Kubelet Server Certificate:** used for incoming connections from the `kube-apiserver`

Write the information into file `/course/3/certificate-info.txt`.

## Key Learning

- **Kubelet Client Cert:** Stored at `/var/lib/kubelet/pki/kubelet-client-current.pem`
- **Kubelet Server Cert:** Stored at `/var/lib/kubelet/pki/kubelet-server-current.pem`
- Inspect cert details with `openssl`: `openssl x509 -in <path> -noout -issuer -text`

<details>
<summary>Solution</summary>

```bash
mkdir -p /course/3

# Inspect Client Cert
echo "=== Kubelet Client Certificate ===" > /course/3/certificate-info.txt
openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -issuer >> /course/3/certificate-info.txt
openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -text | grep -A 2 "Extended Key Usage" >> /course/3/certificate-info.txt

# Inspect Server Cert
echo "=== Kubelet Server Certificate ===" >> /course/3/certificate-info.txt
openssl x509 -in /var/lib/kubelet/pki/kubelet-server-current.pem -noout -issuer >> /course/3/certificate-info.txt
openssl x509 -in /var/lib/kubelet/pki/kubelet-server-current.pem -noout -text | grep -A 2 "Extended Key Usage" >> /course/3/certificate-info.txt
```

</details>
