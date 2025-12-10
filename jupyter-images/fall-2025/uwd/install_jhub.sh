RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
      --namespace $NAMESPACE  \
      --create-namespace \
      --version 4.3.1 \
      --debug \
      --values dask_operator/jupyterhub_config.yaml \
      --values dask_operator/jupyterhub_dask_dashboard_config.yaml \
      --values nfs/jupyterhub_nfs.yaml \
      --values config_standard_storage.yaml --values secrets.yaml
