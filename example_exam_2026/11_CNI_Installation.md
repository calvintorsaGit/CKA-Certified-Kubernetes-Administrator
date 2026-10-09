# Question 11: Container Network Interface (CNI)

## Context
> *Install and configure a CNI of your choice that meet the specified requirements, choose one of the following;*
> 
> *Flannel (v0.26.1) using the manifest: `[kube-flannel.yml](https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml)`*
> 
> *Calico (v3.28.2) using the manifest: `[tigera-operator.yaml](https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml)`*
> 
> *The CNI you choose must:*
> 1. *Let pods communicate with eachother*
> 2. *Support network policy enforcement*
> 3. *Install from manifest*

---

## 🛠️ Playground Setup
*(No playground setup is required. In a real exam scenario for this question, the cluster nodes would currently be in a `NotReady` state because the network plugin is missing).*

---

## ✅ Solution & Discussion

This question tests your understanding of the different capabilities of popular CNI plugins, specifically regarding security.

### Step 1: Choose the Correct CNI
Read the requirements carefully, specifically requirement #2: **Support network policy enforcement**.

- **Flannel:** An excellent, lightweight CNI for basic pod-to-pod communication, but it **does not** natively support Kubernetes NetworkPolicies.
- **Calico:** Provides both robust networking **and** native support for enforcing NetworkPolicies.

Because of requirement #2, you **must choose Calico**.

### Step 2: Install the CNI
Use the `kubectl apply` command to install the chosen manifest directly from the URL provided in the prompt.

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
```

*(Exam Tip: When installing Calico via the Tigera Operator, a second step is often required to apply the `custom-resources.yaml` file to actually trigger the installation. If the exam prompt or docs mention a second file, apply it too. However, sticking strictly to the prompt provided, applying the operator is the required action).*

### Step 3: Verification
Check that the CNI operator pods are spinning up.

```bash
kubectl get pods -n tigera-operator
```

Once the CNI is fully deployed and functioning, the CoreDNS pods will start, and the cluster nodes will transition from `NotReady` to `Ready`.
```bash
kubectl get nodes
```
