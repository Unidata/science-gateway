kubectl delete configmap jhub-custom-templates -n jhub
kubectl create configmap jhub-custom-templates --from-file=login.html -n jhub
