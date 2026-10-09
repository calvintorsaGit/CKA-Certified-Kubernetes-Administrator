# Exam 01: The Dead Worker Node

**Domain:** Troubleshooting (30%)

## Context
You have just switched to a new context in the exam. 
The prompt tells you:
> *The worker node `node01` has suddenly transitioned to a `NotReady` state. Applications scheduled on this node are failing. Fix it so it survives a reboot.*

## Your Task
1. Identify the reason why `node01` is `NotReady`.
2. Fix the issue so that `node01` returns to the `Ready` state.
3. Ensure the fix is persistent across node reboots.

---

## 🛠️ Playground Setup
If you want to simulate this exact scenario in a playground (like Killercoda or your own cluster), run this block on your **worker node** (e.g., `node01`) to "break" it before you start:

```bash
# SSH into your worker node first, then run:

# (cleanup from older attempts - harmless if not present)
sed -i '/brokenConfigField/d' /var/lib/kubelet/config.yaml

# Point the kubelet at a CA file that does not exist
sed -i 's#clientCAFile: .*#clientCAFile: /etc/kubernetes/pki/ca-wrong.crt#' /var/lib/kubelet/config.yaml

# Verify the change landed (should show ca-wrong.crt)
grep clientCAFile /var/lib/kubelet/config.yaml

# Restart so it crash-loops, then disable it so it also won't survive a reboot
systemctl restart kubelet
systemctl disable kubelet
exit
```
*(Wait ~1 minute for the control plane to mark the node as NotReady, then start the exercise!)*

> **Why not just add a fake field?** Modern kubelets use *lenient decoding*: unknown fields like `brokenConfigField: true` only produce a warning in the logs and are ignored. A wrong file path, on the other hand, is a hard failure.

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

Here is exactly how you should think about and solve this in the exam.

### Step 1: Investigation
Whenever a node is `NotReady`, it is almost always an issue with the **kubelet** service on that specific node. 
1. SSH into the broken node: `ssh node01`
2. Check the service status: `systemctl status kubelet`
   *(You will see it is inactive/failed).*
3. Check the logs to find out *why* it failed to start:
   `journalctl -u kubelet --no-pager | tail -n 20`

### Step 2: Finding the Root Cause
In the `journalctl` output, you would see an error similar to this:
`"command failed" err="failed to construct kubelet dependencies: unable to load client CA file /etc/kubernetes/pki/ca-wrong.crt: open /etc/kubernetes/pki/ca-wrong.crt: no such file or directory"`

Confirm which file actually exists:
`ls /etc/kubernetes/pki/`  → you'll see `ca.crt`, not `ca-wrong.crt`.

### Step 3: The Fix
1. Open the configuration file: 
   `vi /var/lib/kubelet/config.yaml`
2. Find the `clientCAFile:` line and change it back to `/etc/kubernetes/pki/ca.crt`. Save and exit.
3. Reload the daemon and start the service:
   ```bash
   systemctl daemon-reload
   systemctl restart kubelet
   ```
4. **CRITICAL EXAM STEP:** The prompt explicitly said *"Ensure the fix is persistent across node reboots."* This means you must enable the service!
   ```bash
   systemctl enable kubelet
   ```
5. `exit` back to your main terminal and verify the node is fixed:
   `kubectl get nodes`
