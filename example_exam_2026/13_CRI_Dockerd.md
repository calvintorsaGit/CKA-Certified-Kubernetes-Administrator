# Question 13: CRI-Dockerd & Sysctl

## Context
> *Set up `cri-dockerd`*
> 
> *Install the Debian package `~/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb` using `dpkg`.*
> 
> *Enable and start the `cri-docker` service.*
> 
> *Configure these system parameters:*
> 1. *Set `net.bridge.bridge-nf-call-iptables` to `1`*
> 2. *Set `net.ipv6.conf.all.forwarding` to `1`*
> 3. *Set `net.ipv4.ip_forward` to `1`*
> 4. *Set `net.netfilter.nf_conntrack_max` to `131072`*

---

## 🛠️ Playground Setup
*(Note: To fully test this, you would need an Ubuntu VM where you have `root`/`sudo` privileges to run `dpkg`, `systemctl`, and modify kernel parameters via `sysctl`. This is a node-level task, not a cluster-level `kubectl` task).*

<br><br><br><br><br><br>

---

## ✅ Solution & Discussion

This question tests your ability to perform node-level administrative tasks, which are essential for Kubernetes cluster installation and troubleshooting.

### Step 1: Install the Debian Package
Use the `dpkg` command line tool to install the provided `.deb` file. You will likely need `sudo` privileges.

```bash
sudo dpkg -i ~/cri-dockerd_0.3.9.3-0.ubuntu-jammy_amd64.deb
```

### Step 2: Enable and Start the Service
Use `systemctl` to enable the service (so it starts automatically on system boot) and start it immediately.

```bash
sudo systemctl enable cri-docker
sudo systemctl start cri-docker

# Alternatively, you can use the shorthand flag:
sudo systemctl enable --now cri-docker
```

Verify that it is running successfully without errors:
```bash
sudo systemctl status cri-docker
```

### Step 3: Configure System Parameters (sysctl)
Kubernetes requires specific kernel parameters to route network traffic properly between pods and nodes. These are configured using `sysctl`.

1. Create a new configuration file in the `/etc/sysctl.d/` directory (e.g., `99-kubernetes-cri.conf`). This ensures your settings persist across reboots.
   ```bash
   sudo vi /etc/sysctl.d/99-kubernetes-cri.conf
   ```

2. Add the requested parameters exactly as specified:
   ```ini
   net.bridge.bridge-nf-call-iptables = 1
   net.ipv6.conf.all.forwarding = 1
   net.ipv4.ip_forward = 1
   net.netfilter.nf_conntrack_max = 131072
   ```

3. Save the file and apply the changes across the system immediately without rebooting:
   ```bash
   sudo sysctl --system
   ```

4. **Verification:** You can verify that a specific value was loaded correctly by querying it:
   ```bash
   sysctl net.ipv4.ip_forward
   ```
