# Exam 12: DNS Resolution for Services and Pods

**Domain:** Services and Networking (20%)

## Context
Kubernetes has an internal DNS server (CoreDNS) that automatically assigns DNS names to Services and Pods. The CKA exam frequently tests your ability to query this internal DNS using temporary troubleshooting pods.

## Your Task
1. Create an nginx pod named `nginx-resolver` using the `nginx` image.
2. Expose it internally using a ClusterIP service called `nginx-resolver-service`.
3. From within the cluster, use the `busybox:1.28` image to verify:
   - DNS resolution of the service name.
   - Network reachability (DNS resolution) of the pod using its IP address.
4. Save the service DNS lookup output to `/root/CKA/nginx.svc` and the pod IP lookup output to `/root/CKA/nginx.pod`.

---

## 🛠️ Playground Setup
```bash
mkdir -p /root/CKA
```

<br><br><br><br><br><br>

---

## 🧠 Concept: What is a DNS lookup?

Inside a Kubernetes cluster, IPs change all the time because pods are constantly dying and being recreated. To solve this, Kubernetes has a built-in phonebook (CoreDNS). 
A "DNS lookup" is simply using the `nslookup` command to ask that phonebook: *"Hey, I have a name. What is the IP address for it?"*

*   **Services:** When you create a Service, it gets a predictable domain name like `nginx-resolver-service.default.svc.cluster.local`.
*   **Pods:** Pods also get DNS names, but they are built using their IP address (with dashes instead of dots). If a pod's IP is `10.244.1.5`, its DNS name is `10-244-1-5.default.pod.cluster.local`. 

In this exam task, you are spinning up a tiny, temporary linux container (`busybox:1.28`) just to run that `nslookup` command from inside the cluster and save the results!

---

## ✅ Solution & Discussion

### Step 1: Create the Pod and Service
First, spin up the pod and expose it:
```bash
# Create the Pod
kubectl run nginx-resolver --image=nginx

# Expose the Pod as a Service (defaults to ClusterIP, port 80 for nginx)
kubectl expose pod nginx-resolver --name=nginx-resolver-service --port=80
```

### Step 2: The Service DNS Lookup
When you create a service, it gets a DNS record in the format: `<service-name>.<namespace>.svc.cluster.local`. If you are querying from the same namespace, you can just use `<service-name>`.

Run a temporary `busybox:1.28` pod to query the DNS of the service:
```bash
kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service > /root/CKA/nginx.svc
```
*(Note: Using `--rm -it` ensures the pod deletes itself immediately after running the command, keeping your cluster clean).*

### Step 3: The Pod DNS Lookup
Pods also get DNS records, but their format relies on their IP address with **dashes instead of dots**. The format is: `<pod-ip-with-dashes>.<namespace>.pod.cluster.local`.

1. Find the Pod's IP address:
   ```bash
   kubectl get pod nginx-resolver -o wide
   # Let's pretend the IP is 10.244.1.5
   ```

2. Convert the dots to dashes: `10-244-1-5`
3. Construct the Pod DNS name: `10-244-1-5.default.pod.cluster.local` (Assuming you are in the default namespace).

4. Run the query:
   ```bash
   kubectl run test-dns --image=busybox:1.28 --rm -it --restart=Never -- nslookup 10-244-1-5.default.pod.cluster.local > /root/CKA/nginx.pod
   ```

### 💡 Why `busybox:1.28`?
You might wonder why the exam specifically asks for version `1.28`. Newer versions of the `busybox` image (like 1.29+) had a known bug with `nslookup` interacting with Kubernetes DNS. The exam uses `1.28` to ensure the command works properly!
