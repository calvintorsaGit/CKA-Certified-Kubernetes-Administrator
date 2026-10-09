# CoreDNS Configuration

## Task Description
Solve this question on: `ssh cka5774`

The CoreDNS configuration in the cluster needs to be updated:
1. Make a backup of the existing configuration YAML and store it at `/course/16/coredns_backup.yaml`. You should be able to fast recover from the backup.
2. Update the CoreDNS configuration in the cluster so that `SERVICE.NAMESPACE.custom-domain` resolves the same as `SERVICE.NAMESPACE.cluster.local` (in addition to it).
3. Test your configuration from a Pod with busybox:1 image. 

---

## Solution Guide

### 1. SSH into the specified node
Ensure you are on the correct node for this task:
```bash
ssh cka5774
```

### 2. Backup the existing CoreDNS ConfigMap
CoreDNS stores its configuration in a ConfigMap named `coredns` in the `kube-system` namespace. You can back it up using the following command:
```bash
mkdir -p /course/16
kubectl get configmap coredns -n kube-system -o yaml > /course/16/coredns_backup.yaml
```

### 3. Update the CoreDNS ConfigMap
To make `custom-domain` resolve the same as `cluster.local`, you can use the CoreDNS `rewrite` plugin. It will intercept DNS requests for `custom-domain` and rewrite them to `cluster.local` before processing.

Open the ConfigMap for editing:
```bash
kubectl edit configmap coredns -n kube-system
```

Under the `Corefile` data, locate the `.:53 {` block. Add the `rewrite` instruction immediately inside that block, like this:
```yaml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        rewrite name suffix custom-domain cluster.local  # <-- ADD THIS LINE
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        ...
```
Save and close the editor. CoreDNS automatically watches for changes in its ConfigMap and reloads its configuration gracefully, so there is no need to manually restart the pods. It might take up to a minute to take effect.

*Alternative approach: You can also just add `custom-domain` to the `kubernetes` block: `kubernetes cluster.local custom-domain in-addr.arpa ip6.arpa {`*

### 4. Test the configuration
Spin up a temporary busybox pod to test the DNS resolution:
```bash
kubectl run busybox --image=busybox:1 --restart=Never --rm -it -- sh
```

Once inside the busybox shell, run both queries to confirm they resolve correctly:
```bash
# Test the original domain
nslookup kubernetes.default.svc.cluster.local

# Test the newly added custom domain
nslookup kubernetes.default.svc.custom-domain
```
Both commands should return the IP address of the `kubernetes` service.

### 5. Exit out
```bash
# Exit busybox
exit

# Exit the node
exit
```
