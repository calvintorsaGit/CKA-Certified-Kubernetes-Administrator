# Exercise 45 — Multi-Container Pod with Downward API & Log Pipeline

> Related: [README — Workloads & Scheduling](../../README.md#domain-1--workloads--scheduling-15) | **Updated May 2026**

Build a 3-container Pod pattern sharing an `emptyDir` volume, exposing NodeName via Downward API, appending timestamps, and tailing logs to stdout.

## Tasks

Create Pod `multi-container-playground` in `default`:
1. Volume attached and mounted into each container (not shared across pods).
2. Container `c1` (`nginx:1-alpine`): Expose node name as environment variable `MY_NODE_NAME` via Downward API (`fieldRef: spec.nodeName`).
3. Container `c2` (`busybox:1`): Append `date` every second into `/vol/date.log`.
4. Container `c3` (`busybox:1`): Stream `/vol/date.log` to stdout using `tail -f`.

<details>
<summary>Solution</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-playground
  namespace: default
spec:
  volumes:
  - name: shared-vol
    emptyDir: {}
  containers:
  - name: c1
    image: nginx:1-alpine
    env:
    - name: MY_NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    volumeMounts:
    - name: shared-vol
      mountPath: /vol
  - name: c2
    image: busybox:1
    command: ["sh", "-c", "while true; do date >> /vol/date.log; sleep 1; done"]
    volumeMounts:
    - name: shared-vol
      mountPath: /vol
  - name: c3
    image: busybox:1
    command: ["sh", "-c", "tail -f /vol/date.log"]
    volumeMounts:
    - name: shared-vol
      mountPath: /vol
```

</details>
