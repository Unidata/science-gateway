- [JupyterHub Dask Cluster](#h-76BD4FCE)
  - [Introduction](#h-CF10AC71)
  - [Dockerfile](#h-71E0655F)
  - [Removing Orphaned Dask Resources](#h-3004DFC8)
  - [Post-mortem](#h-CFDE3B61)



<a id="h-76BD4FCE"></a>

# JupyterHub Dask Cluster


<a id="h-CF10AC71"></a>

## Introduction

Once again, [the instructions](https://www.zonca.dev/posts/2025-11-17-dask-operator-jupyterhub) to build a JupyterHub Dask cluster on Jetstream2 have changed significantly this year. In particular, the manner in which the Dask cluster is launched is different due to Magnum. An important advantage with the Magnum approach is you no longer have to pre-provision resources ahead of time so deployment is simpler. Moreover, fetching the ERA5 data from the GDEX (formerly RDA) is appreciably different compared to prior years. Finally, check out the [install<sub>jhub.sh</sub>](file:///Users/chastang/git/science-gateway/jupyter-images/fall-2025/uwd/install_jhub.sh) script for additional information.


<a id="h-71E0655F"></a>

## Dockerfile

In contrast to previous years, there is only one `Dockerfile` required, but it must be referenced in three places:

1.  `secrets.yaml`
2.  `config_standard_storage.yaml`
3.  The notebook itself where `KubeCluster` is instantiated. See `Dask.ipynb` for an example, how to access the Dask Dashboard, and how to shutdown the `cluster.close()` in order to not leak resources.


<a id="h-3004DFC8"></a>

## Removing Orphaned Dask Resources

Sometimes when working with Dask clusters, users will forget to shutdown the cluster perhaps because the notebook had trouble finishing to completion. In that case, you may wish to clean up orphaned resources. Note that the command below will clean up all Dask clusters so use with caution in order not to interrupt a users work.

```sh
kubectl delete pod -n jhub $(kubectl get pods -n jhub | grep dask-worker | awk '{print $1}')
kubectl delete pod -n jhub $(kubectl get pods -n jhub | grep dask-scheduler | awk '{print $1}')
```


<a id="h-CFDE3B61"></a>

## Post-mortem

Not everything went smoothly during the classroom exercise. I am leaving the comment below for next time we have to do this so that we can improve upon what we did here. One idea was that we considered is to pre-provision large size VMs so that pods can immediately be accommodated and the autoscaler never has to scale up.

"It went ok, but a lot of our clusters failed when all 25 of us attempted to run things, and we had a lot of slowdowns outside of that. That being said, I encouraged students to try the exercises on their own time (until Friday) to see the speed-ups that they can get. I was able to run the notebook fine on my own and get things done pretty quickly, so I know it all works!"

Finally, never had the chance to port over `wrf.ipynb` to the new Dask methodology. That will have to be done next time.
