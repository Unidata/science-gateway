- [Setting Up a Shared User Volume (Home Directories)](#h-FDDAB6AE)
    - [Create an OpenStack Volume](#h-707BF30E)
- [Deploy the In-Cluster NFS Server](#h-B7E2C274)
- [Install the Chart](#h-54D69357)
- [Create the PV and PVC for JupyterHub](#h-B5E67651)
- [Mount the Shared Volume in Single-User Pods](#h-28C3E0B3)
- [Shared Data Volume for All Users](#h-3ACFA39D)
  - [One-Time: Create the Shared Directory](#h-8DDD5A67)
  - [Mount Shared and Home Directories in JupyterHub](#h-57660687)
- [Install or Upgrade JupyterHub](#h-D64BF7AF)



<a id="h-FDDAB6AE"></a>

# Setting Up a Shared User Volume (Home Directories)

Setting up a single shared volume for all JupyterHub users offers a more robust user experience in a couple respects:

1.  Fewer points of failure and avoiding volume attachment problems.
2.  Quicker login experience as the user does not have to wait for the disk attachment.

We are using the solution from the `2i2c-org/jupyterhub-home-nfs` project to achieve this outcome. These instructions were created based on the [jupyterhub-home-nfs](https://github.com/2i2c-org/jupyterhub-home-nfs) repository `README`.


<a id="h-707BF30E"></a>

### Create an OpenStack Volume

Adjust the size based on number of users and their expected quota expectations. Note the ID. You will need that next.

```sh
openstack volume create --size 500 $CLUSTER-nfs-homedirs
openstack volume show unidata-jupyterhub-nfs-homedirs -f value -c id
```


<a id="h-B7E2C274"></a>

# Deploy the In-Cluster NFS Server

Adjust `values-nfs.yaml` according the volume ID (see `volumeId`).

```yaml
# values-nfs.yaml
fullnameOverride: ""
nfsServer:
  enableClientAllowlist: false
quotaEnforcer:
  enabled: true
  config:
    QuotaManager:
      # per-user hard quota in GiB
      hard_quota: 10
      uid: 1000
      gid: 100
      paths: ["/export"]
prometheusExporter:
  enabled: true

# Use OpenStack Cinder volume created above
openstack:
  enabled: true
  volumeId: "<volume_id>"
```


<a id="h-54D69357"></a>

# Install the Chart

```sh
helm upgrade --install jupyterhub-home-nfs \
  oci://ghcr.io/2i2c-org/jupyterhub-home-nfs/jupyterhub-home-nfs \
  --namespace jupyterhub-home-nfs --create-namespace \
  --values values-nfs.yaml
```

Next record the NFS ClusterIP because you will need it next:

```sh
kubectl get svc -n jupyterhub-home-nfs
```


<a id="h-B5E67651"></a>

# Create the PV and PVC for JupyterHub

Adjust `jhub-nfs-pv-pvc.yaml` according the NFS ClusterIP.

```yaml
# PV (cluster-scoped)
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jupyterhub-home-nfs
spec:
  capacity:
    storage: 1Mi
  accessModes: [ReadWriteMany]
  persistentVolumeReclaimPolicy: Retain
  mountOptions:
    - vers=4.1
    - proto=tcp
    - rsize=1048576
    - wsize=1048576
    - timeo=600
    - hard
    - retrans=2
    - noresvport
  nfs:
    server: <NFS ClusterIP>
    path: /
---
# PVC (namespace-scoped)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: home-nfs
  namespace: jhub
spec:
  accessModes: [ReadWriteMany]
  volumeName: jupyterhub-home-nfs
  storageClassName: ""
  resources:
    requests:
      storage: 1Mi
```

And now apply it:

```sh
kubectl apply -f jhub-nfs-pv-pvc.yaml
```


<a id="h-28C3E0B3"></a>

# Mount the Shared Volume in Single-User Pods

For example:

```yaml
singleuser:
  storage:
    type: none
    extraVolumes:
      - name: home-nfs
        persistentVolumeClaim:
          claimName: home-nfs
    extraVolumeMounts:
      - name: home-nfs
        mountPath: /home/jovyan
        subPath: "{username}"
```


<a id="h-3ACFA39D"></a>

# Shared Data Volume for All Users

This approach reuses the existing `jupyterhub-home-nfs` in-cluster NFS server used for user home directories, and adds a single shared directory that is mounted into every user pod. No additional NFS server or volume is required.


<a id="h-8DDD5A67"></a>

## One-Time: Create the Shared Directory

Create a Kubernetes Job with `init-shared-dir.yaml` to initialize the shared directory on the NFS volume. The PV is rooted at `/`, so the directory is created at the filesystem root.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: init-home-nfs-shared
  namespace: jhub
spec:
  backoffLimit: 1
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: init
          image: busybox:1.36
          command:
            - /bin/sh
            - -c
            - |
              set -eu
              mkdir -p /mnt/_shared
              chown 1000:100 /mnt/_shared
              chmod 0775 /mnt/_shared
              chmod g+s /mnt/_shared
              ls -ld /mnt/_shared
          volumeMounts:
            - name: home-nfs
              mountPath: /mnt
      volumes:
        - name: home-nfs
          persistentVolumeClaim:
            claimName: home-nfs
```

Apply and remove the Job:

```sh
kubectl apply -f init-shared-dir.yaml
kubectl logs -n jhub job/init-home-nfs-shared
kubectl delete -n jhub job/init-home-nfs-shared
```


<a id="h-57660687"></a>

## Mount Shared and Home Directories in JupyterHub

Mount both per-user homes and the shared directory from the same PVC.

```yaml
singleuser:
  storage:
    type: none
    extraVolumes:
      - name: home-nfs
        persistentVolumeClaim:
          claimName: home-nfs
    extraVolumeMounts:
      - name: home-nfs
        mountPath: /home/jovyan
        subPath: "{username}"

      - name: home-nfs
        mountPath: /share
        subPath: "_shared"
```


<a id="h-D64BF7AF"></a>

# Install or Upgrade JupyterHub

Upgrade or install JupyterHub as usual.

```sh
bash install_jhub.sh
```
