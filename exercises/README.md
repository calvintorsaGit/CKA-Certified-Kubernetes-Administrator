# CKA Exercises

33 hands-on labs covering all seven CKA exam domains. Each one has a task list, hints (use them — they save time), verification commands, and a full solution behind a spoiler tag.

I ordered these roughly by difficulty. If you're short on time, prioritize 09 (kubeadm), 11 (troubleshooting), 29 (etcd fix), and 28 (NetworkPolicy) — those cover the highest-weight domains and represent real exam patterns.

**New in v2.0:** Exercises 23-49 based on 2026 real exam feedback. These test advanced scenarios and common failure patterns.

| #   | Exercise                                                         | Domain                 | Difficulty | Time   |
| -----| ------------------------------------------------------------------| ------------------------| ------------| --------|
| 01  | [Pod Basics](01-pod-basics/)                                     | Workloads & Scheduling | Easy       | 10 min |
| 02  | [Multi-Container Pod](02-multi-container-pod/)                   | Workloads & Scheduling | Medium     | 15 min |
| 03  | [ConfigMap & Secret](03-configmap-secret/)                       | Workloads & Scheduling | Easy       | 10 min |
| 04  | [RBAC](04-rbac/)                                                 | Cluster Architecture   | Medium     | 15 min |
| 05  | [NetworkPolicy](05-networkpolicy/)                               | Services & Networking  | Medium     | 20 min |
| 06  | [Deployment Rollout](06-deployment-rollout/)                     | Workloads & Scheduling | Easy       | 10 min |
| 07  | [StatefulSet](07-statefulset/)                                   | Workloads & Scheduling | Medium     | 15 min |
| 08  | [Node Drain & Cordon](08-node-drain-cordon/)                     | Cluster Architecture   | Easy       | 10 min |
| 09  | [kubeadm Upgrade](09-kubeadm-upgrade/)                           | Cluster Architecture   | Hard       | 25 min |
| 10  | [Static Pod](10-static-pod/)                                     | Workloads & Scheduling | Easy       | 10 min |
| 11  | [Troubleshoot Cluster](11-troubleshoot-cluster/)                 | Troubleshooting        | Hard       | 25 min |
| 12  | [Storage — PV & PVC](12-storage-pv-pvc/)                         | Storage                | Medium     | 15 min |
| 13  | [Helm Install & Upgrade](13-helm-install-upgrade/)               | Cluster Architecture   | Medium     | 15 min |
| 14  | [Kustomize Overlays](14-kustomize-overlays/)                     | Cluster Architecture   | Medium     | 15 min |
| 15  | [Gateway API](15-gateway-api/)                                   | Services & Networking  | Medium     | 20 min |
| 16  | [Horizontal Pod Autoscaler](16-hpa/)                             | Workloads & Scheduling | Medium     | 15 min |
| 17  | [kubectl debug](17-kubectl-debug/)                               | Troubleshooting        | Medium     | 15 min |
| 18  | [CRI-dockerd Setup](18-cri-dockerd-setup/)                       | Cluster Architecture   | Medium     | 15 min |
| 19  | [Classic Ingress](19-ingress-classic/)                           | Services & Networking  | Medium     | 15 min |
| 20  | [Pod Security Standards](20-pod-security-standards/)             | Cluster Architecture   | Medium     | 15 min |
| 21  | [Jobs & CronJobs](21-jobs-cronjobs/)                             | Workloads & Scheduling | Medium     | 15 min |
| 22  | [PriorityClass](22-priorityclass/)                               | Workloads & Scheduling | Medium     | 15 min |
| 23  | [Resource Requests Tuning](23-resource-requests-tuning/)         | Workloads & Scheduling | Hard       | 20 min |
| 24  | [PriorityClass Patch](24-priorityclass-patch/)                   | Workloads & Scheduling | Medium     | 15 min |
| 25  | [Storage WaitForFirstConsumer](25-storage-waitforfirstconsumer/) | Storage                | Hard       | 20 min |
| 26  | [CRI-dockerd Installation](26-cri-dockerd-setup/)                | Cluster Architecture   | Hard       | 30 min |
| 27  | [CNI Tigera/Calico Install](27-cni-tigera-install/)              | Services & Networking  | Hard       | 30 min |
| 28  | [Complex NetworkPolicy](28-network-policy-complex/)              | Services & Networking  | Hard       | 25 min |
| 29  | [Troubleshoot etcd Endpoint](29-troubleshoot-etcd-endpoint/)     | Troubleshooting        | Hard       | 20 min |
| 30  | [TLS Configuration Update](30-tls-configuration-update/)         | Security               | Hard       | 20 min |
| 31  | [Argo CD GitOps Setup](31-argocd-gitops-setup/)                  | Cluster Architecture   | Hard       | 25 min |
| 32  | [Argo CD Installation via Helm](32-argocd-helm-install/)         | Cluster Architecture   | Hard       | 20 min |
| 33  | [NGINX SSL Protocols Update](33-nginx-ssl-protocols/)            | Cluster Architecture   | Medium     | 15 min |
| 34  | [CoreDNS FQDN ConfigMap](34-coredns-fqdn-configmap/)             | Services & Networking  | Medium     | 15 min |
| 35  | [Kubelet TLS Bootstrapping](35-kubelet-tls-bootstrapping/)       | Security               | Hard       | 20 min |
| 36  | [Readiness Probe Dependency](36-readiness-probe-dependency/)     | Workloads & Scheduling | Medium     | 15 min |
| 37  | [kubectl Sorting Scripts](37-kubectl-sorting-scripts/)           | Troubleshooting        | Easy       | 10 min |
| 38  | [Fix Dead Kubelet Service](38-fix-dead-kubelet/)                 | Troubleshooting        | Medium     | 15 min |
| 39  | [etcd Version & Snapshot](39-etcd-version-snapshot/)             | Cluster Architecture   | Medium     | 15 min |
| 40  | [Controlplane Architecture Report](40-controlplane-components-report/)| Cluster Architecture | Medium   | 15 min |
| 41  | [Manual Pod Scheduling](41-manual-pod-scheduling/)               | Workloads & Scheduling | Medium     | 15 min |
| 42  | [StorageClass Job PVC Integration](42-storageclass-job-pvc/)     | Storage                | Medium     | 15 min |
| 43  | [Secret Mount & Env Vars](43-secret-mount-env/)                 | Workloads & Scheduling | Medium     | 15 min |
| 44  | [Schedule Controlplane Only](44-schedule-controlplane-only/)     | Workloads & Scheduling | Medium     | 15 min |
| 45  | [Multi-Container Downward API & Logs](45-multicontainer-downward-api-logs/)| Workloads & Scheduling | Medium | 15 min |
| 46  | [Cluster Info Audit](46-cluster-info-audit/)                     | Services & Networking  | Medium     | 15 min |
| 47  | [Cluster Events Logging](47-cluster-events-logging/)             | Troubleshooting        | Medium     | 15 min |
| 48  | [API Resources Crowded Namespace](48-api-resources-crowded-namespace/)| Cluster Architecture | Medium  | 15 min |
| 49  | [Kustomize Operator RBAC](49-kustomize-operator-rbac/)           | Cluster Architecture   | Hard       | 20 min |

| Domain | Weight | Exercises |
|---|---|---|
| Troubleshooting | 30% | 11, 17, 29, 37, 38, 47 |
| Cluster Architecture | 25% | 04, 08, 09, 13, 14, 18, 20, 26, 31, 32, 33, 39, 40, 48, 49 |
| Services & Networking | 20% | 05, 15, 19, 27, 28, 34, 46 |
| Workloads & Scheduling | 15% | 01, 02, 03, 06, 07, 10, 16, 21, 22, 23, 24, 36, 41, 43, 44, 45 |
| Storage | 10% | 12, 25, 42 |
| Security | 10% | 30, 35 |

## How to Use

1. Read the exercise description
2. Try the tasks without looking at the solution
3. Use the hints if you're stuck
4. Check your work with the verification steps
5. Compare against the solution
6. Run cleanup before moving to the next exercise

Every exercise assumes you have a running cluster (kind, minikube, or kubeadm) and the aliases from [`scripts/exam-setup.sh`](../scripts/exam-setup.sh).
