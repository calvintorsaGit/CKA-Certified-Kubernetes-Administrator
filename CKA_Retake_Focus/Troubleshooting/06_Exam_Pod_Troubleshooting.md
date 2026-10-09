# Exam 06: Pod Troubleshooting (CrashLoopBackOff)

**Domain:** Troubleshooting (30%)

## Context
> *A developer deployed an application named `payment-processor`, but it keeps crashing.*

## Your Task
1. Find the `payment-processor` pod in the `default` namespace.
2. Identify why it is in a `CrashLoopBackOff` state.
3. Fix the issue so the pod reaches the `Running` state.

---

## 🛠️ Playground Setup
```bash
# This creates a pod with a deliberately invalid command
kubectl run payment-processor --image=nginx --command -- nginx -g 'daemon bad;'
```
<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

### Step 1: Investigate
1. Check the pod status:
   `kubectl get pods`
2. Check the logs (this is usually the fastest way to find application crashes):
   `kubectl logs payment-processor`
   *Output will say: `nginx: [emerg] invalid parameter "bad"`*
3. Check the pod definition to see where the command is misconfigured:
   `kubectl describe pod payment-processor`

### Step 2: Fix it
You cannot edit a pod's command directly while it is running. You must export it, fix it, and replace it.

1. Export the pod to YAML:
   `kubectl get pod payment-processor -o yaml > pod.yaml`
2. Edit the YAML:
   `vi pod.yaml`
   *(Find the `command:` or `args:` array and change `'daemon bad;'` to `'daemon off;'`)*
3. Delete the broken pod and apply the fixed one:
   ```bash
   kubectl replace --force -f pod.yaml
   ```
4. Verify:
   `kubectl get pods`
