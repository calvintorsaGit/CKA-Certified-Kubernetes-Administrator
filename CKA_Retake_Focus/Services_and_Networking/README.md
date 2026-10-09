# Services and Networking

## Focus Areas (20% of Exam)

### 1. Services
- Creating and configuring ClusterIP, NodePort, and LoadBalancer services.
- Mapping Services to Pods using Selectors.
- Understanding the relationship between Services and Endpoints.

### 2. NetworkPolicies
- Writing Ingress and Egress NetworkPolicies.
- Securing namespaces by denying all traffic by default, then allowing specific ports/labels.
- Using `podSelector` and `namespaceSelector`.

### 3. Ingress
- Creating Ingress resources to route HTTP/HTTPS traffic.
- Configuring Ingress rules, paths, and hostnames.
- Understanding Ingress Controllers.

### 4. DNS (CoreDNS)
- Understanding how Kubernetes DNS works (`service.namespace.svc.cluster.local`).
- Modifying the CoreDNS ConfigMap to add custom rewrites or stubs.

### Practice Exercises to Master:
- Create a NetworkPolicy that isolates a backend database from all pods except a specific frontend tier.
- Expose an application using a NodePort service and verify accessibility.
- Set up an Ingress rule that routes `/v1` and `/v2` to different backend Services.

---

## Practice Checklist (exercises already in this repo)

- [ ] [05-networkpolicy](../../exercises/05-networkpolicy)
- [ ] [28-network-policy-complex](../../exercises/28-network-policy-complex)
- [ ] [34-coredns-fqdn-configmap](../../exercises/34-coredns-fqdn-configmap)
- [ ] [19-ingress-classic](../../exercises/19-ingress-classic)
- [ ] [15-gateway-api](../../exercises/15-gateway-api)
- [ ] [33-nginx-ssl-protocols](../../exercises/33-nginx-ssl-protocols)
- [ ] [30-tls-configuration-update](../../exercises/30-tls-configuration-update)
- [ ] killer.sh: [network_policy.md](../../killer_sh_exam_1/network_policy.md)
- [ ] killer.sh: [coredns_configuration.md](../../killer_sh_exam_1/coredns_configuration.md)

## Must-Know Commands

```bash
kubectl expose deploy <name> --port=80 --target-port=8080 --type=NodePort
kubectl get svc,ep -n <ns>                       # endpoints empty = bad selector
kubectl get pods -n <ns> --show-labels           # check labels before NetPol
kubectl run tmp --image=busybox:1 --rm -it --restart=Never -- nslookup <svc>.<ns>
kubectl -n <ns> exec <pod> -- curl -s -m 2 <ip>:<port>   # test NetPol
kubectl -n kube-system edit cm coredns           # back it up first!
```
