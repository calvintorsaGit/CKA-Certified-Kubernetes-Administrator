#!/bin/bash
# Setup script for Exercise 35: Kubelet TLS Bootstrapping & Certificate Inspection

set -e

echo "=== Setting up environment for Exercise 35 ==="

# 1. Create target directories
sudo mkdir -p /var/lib/kubelet/pki
sudo mkdir -p /course/3
sudo chmod 777 /course/3 2>/dev/null || mkdir -p /course/3

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# 2. Generate Root CA
openssl genrsa -out ca.key 2048 2>/dev/null
openssl req -new -x509 -days 365 -key ca.key -out ca.crt -subj "/CN=kubernetes-ca" 2>/dev/null

# 3. Generate Kubelet Client Certificate (clientAuth)
openssl genrsa -out kubelet-client.key 2048 2>/dev/null
openssl req -new -key kubelet-client.key -out kubelet-client.csr -subj "/CN=system:node:node1/O=system:nodes" 2>/dev/null

cat <<EOF > client-ext.cnf
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
EOF

openssl x509 -req -in kubelet-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kubelet-client.crt -days 365 -extfile client-ext.cnf 2>/dev/null

# 4. Generate Kubelet Server Certificate (serverAuth)
openssl genrsa -out kubelet-server.key 2048 2>/dev/null
openssl req -new -key kubelet-server.key -out kubelet-server.csr -subj "/CN=node1" 2>/dev/null

cat <<EOF > server-ext.cnf
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
EOF

openssl x509 -req -in kubelet-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kubelet-server.crt -days 365 -extfile server-ext.cnf 2>/dev/null

# 5. Deploy certificates to /var/lib/kubelet/pki/
sudo cp kubelet-client.crt /var/lib/kubelet/pki/kubelet-client-current.pem
sudo cp kubelet-server.crt /var/lib/kubelet/pki/kubelet-server-current.pem
sudo chmod 644 /var/lib/kubelet/pki/kubelet-client-current.pem
sudo chmod 644 /var/lib/kubelet/pki/kubelet-server-current.pem

# Clean up
rm -rf "$TMP_DIR"

echo "✓ Exercise 35 environment set up successfully!"
echo "Certificates created at:"
echo "  - /var/lib/kubelet/pki/kubelet-client-current.pem"
echo "  - /var/lib/kubelet/pki/kubelet-server-current.pem"
echo "Target output directory /course/3 is ready."
