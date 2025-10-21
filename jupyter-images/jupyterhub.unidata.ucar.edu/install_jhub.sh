RELEASE=jhub
NAMESPACE=jhub

# kubectl apply -f jhub-nfs-pv-pvc.yaml
# kubectl create configmap jhub-custom-templates --from-file=login.html -n jhub   --dry-run=client -o yaml

helm upgrade --install jhub jupyterhub/jupyterhub \
  --namespace $NAMESPACE  \
  --version 4.2.0 \
  --values config_standard_storage.yaml \
  --values secrets.yaml \
  --values values-idps.yaml \
  --values values-custom-ui.yaml \
  --debug

