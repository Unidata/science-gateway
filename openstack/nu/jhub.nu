# A scratch script where I do everything at once before actually making it good

# Standard logging library
use std/log
export-env {
  use std/log []
}
$env.NU_LOG_FORMAT = "%ANSI_START%[ %DATE% ] | %LEVEL% | %MSG%%ANSI_STOP%"

let config_path = "jhub-workflow-config.yaml"
mut config = open $config_path

# ##################################################
# Calculate derived values
# ##################################################

# - max number of worker nodes

# ##################################################
# Helper functions
# ##################################################
def "jhub set start" [
  section: string
  config_path?: string = "./jhub-workflow-config.yaml"
] {
  if not ($config_path | path exists) {
    $"Config path ($config_path) does not exist! Aborting"
    | tee {log error $in }
    | error make {msg: $in}
  }
  
  let started = [$section "started"] | into cell-path
  let creation_time = [$section "creation_time"] | into cell-path

  $config
  | update $started true
  | update $creation_time (date now)
  | tee {save -f $config_path } # tee to also return the updated config
}

# Wait until "ready_condition" returns true or until waiting for "timeout" amount of time
# Returns the ready status
def "wait with timeout" [
  ready_condition: closure # Closure to run to determine ready status; must return a boolean
  start_time: datetime # Start time to reference when determining timeout
  timeout: duration # How long to wait until the process is determined to have timed out
  wait_interval: duration # How long to wait between ready queries
]: any -> bool {
  mut ready = false
  
  while not $ready and ((date now) - $start_time) < $timeout {
    $ready = do ready_condition
    log info $"[ Time elapsed ((date now) - $start_time) ]" 
    sleep $wait_interval
  }

  $ready
}

# ##################################################
# Main functions
# ##################################################

def "jhub create cluster" [
  --config_path (-c): string = "./jhub-workflow-config.yaml" # Path to config file
] {
  mut config = open $config_path
  let cluster = $config.cluster
  let ignore_null = ["creation_time"]
  if (
    $cluster
    | reject ...$ignore_null
    | flatten
    | flatten
    | traspose key value
    | any {|e| $e.value == null }
  ) {
    $"Some configuration values are unset. Please set them in ($config_path)"
    | tee {log error $in }
    | error make {msg: $in }
  }

  nos coe cluster create \
      --cluster-template $cluster.template \
      --master-count $cluster.master.count \
      --node-count $cluster.worker.count \
      --master-flavor $cluster.master.flavor \
      --flavor $cluster.worker.flavor \
      --labels auto_scaling_enabled=$"($cluster.autoscaling)" \
      --labels min_node_count=1 \
      --labels max_node_count=1 \
      --fixed-network auto_allocated_network \
      $cluster.name
  
  # Book keeping
  $cluster = (jhub set start "cluster").cluster
  
  # Wait for the cluster to finish creating or stop on timeout
  log info $"Creating (ansi pb)($K8S_CLUSTER_NAME) ..."
  $cluster.ready = wait with timeout \
    {
      (nos cluster show $cluster.name).status == "CREATION_COMPLETE"
    } \
    $cluster.creation_time \
    ($cluster.timeout | into duration) \
    1min

  $config.cluster = $cluster
  $config | save -f $config_path
  
  if not $cluster.ready {
    "Cluster creation failed! Aborting ..."
      | tee {log error $in }
      | error make {msg: $in }
  } else {
    log info "Creation complete!"
    nos coe cluster show $cluster.name
  }
}

# ##################################################
# Fetch the kubectl config
# ##################################################

def "jhub create kubectl config" [
  --config_path (-c): string = "./jhub-workflow-config.yaml" # Path to config file
] {
  mut $config = open $config_path
  mut $kubectl_cfg = $config.kubectl_cfg
  let ignore_null = ["creation_time"]

  if (
    $kubectl_cfg
      | traspose key value
      | any {|e| $e.value == null }
  ) {
    $"Some configuration values are unset. Please set them in ($config_path)"
      | tee {log error $in }
      | error make {msg: $in }
  }
  
  mkdir ~/.kube
  # Do this in a separate shell process, so we don't need to `cd` back to wherever we are
  nu -c 'cd ~/.kube; openstack coe cluster config $K8S_CLUSTER_NAME --force'
  
  # Book keeping
  $kubectl_cfg = (jhub set start "kubectl_cfg").kubectl_cfg
  
  # Wait for the config to finish creating or stop on timeout
  log info $"Fetching (ansi pb)~/.kube/config ..."
  $kubectl_cfg.ready = wait with timeout \
    {
      ("~/.kube/config" | path exists) and (^kubectl get nodes | complete).exit_code == 0
    }
    $kubectl_cfg.creation_time \
    ($kubectl_cfg.timeout | into duration) \
    20sec

  $config.kubectl_cfg = $kubectl_cfg
  $config | save -f $config_path
  
  if not $kubectl_cfg.ready {
    "Kube config creation failed! Aborting ..."
      | tee {log error $in }
      | error make {msg: $in }
  } else {
    log info "Creation complete!"
    kn get nodes
  }
}

# ##################################################
# Create a node group
# ##################################################

# mut $config = open $config_path
# mut $nodegroup = $config.nodegroup
#
# if (
#   $nodegroup
#     | traspose key value
#     | any {|e| $e.value == null }
# ) {
#   $"Some configuration values are unset. Please set them in ($config_path)"
#     | tee {log error $in }
#     | error make {msg: $in }
# }
#
# nos coe nodegroup create $CLUSTER $NODE_GROUP_NAME \
#     --node-count 1 \
#     --flavor $NODE_GROUP_FLAVOR
#     --labels auto_scaling_enabled=true \
#     --min-nodes 1 \
#     --max-nodes $NODE_GROUP_MAX_NODES
#
# # Book keeping
# $nodegroup.started = true
# $nodegroup.creation_time = date now
# $config.nodegroup = $nodegroup
# $config | save -f $config_path
#
# # Wait for the nodegroup to finish creating or stop on timeout
# log info $"Creating nodegroup (ansi pb)($nodegroup.name) ..."
# $nodegroup.timeout = $nodegroup.timeout | into duration
#
# # $nodegroup.ready is "false" by default
# while not $nodegroup.ready and not ((date now) - $nodegroup.creation_time) < $nodegroup.timeout {
#   $nodegroup.ready = (nos coe nodegroup show $config.cluster.name $nodegroup.name).status
#     | tee {log info $"[ Time elapsed ((date now) - $nodegroup.creation_time) ] Creation status: ($in)" }
#     | $in == "CREATE_COMPLETE"
#   sleep 1min
# }
#
# if not $nodegroup.ready {
#   "Nodegroup creation failed! Aborting ..."
#     | tee {log error $in }
#     | error make {msg: $in }
# } else {
#   log info "Creation complete!"
#   $config.nodegroup = $nodegroup
#   $config | save -f $config_path
#   nos coe nodegroup show $config.cluster.name $nodegroup.name
# }
#
# # ##################################################
# # Deploy an ingress resource
# # ##################################################
#
# mut $config = open $config_path
# mut $ingress = $config.ingress
# let rej = ["ip"]
#
# if (
#   $ingress
#     | reject ...$rej
#     | traspose key value
#     | any {|e| $e.value == null }
# ) {
#   $"Some configuration values are unset. Please set them in ($config_path)"
#     | tee {log error $in }
#     | error make {msg: $in }
# }
#
# helm upgrade --install ingress-nginx ingress-nginx \
#     --repo https://kubernetes.github.io/ingress-nginx \
#     --namespace ingress-nginx --create-namespace \
#     --set 'controller.nodeSelector.capi\.stackhpc\.com/node-group=default-worker'
#
# # Book keeping
# $ingress.started = true
# $ingress.creation_time = date now
# $config.ingress = $ingress
# $config | save -f $config_path
#
# # Wait for the ingress to finish creating or stop on timeout
# log info $"Creating (ansi pb) ingress..."
# $ingress.timeout = $ingress.timeout | into duration
#
# # $ingress.ready is "false" by default
# while not $ingress.ready and not ((date now) - $ingress.creation_time) < $ingress.timeout {
#   $ingress.ip = try {
#     kn --full get service -n ingress-nginx
#     | get items
#     | where {|e| $e.metadata.name == "ingress-nginx-controller" }
#     | first
#     | get status.LoadBalancer.ingress.0.ip
#   }
#   $ingress.ready = $ingress.ip != null
#   sleep 30sec
# }
#
# if not $ingress.ready {
#   "Ingress creation failed! Aborting ..."
#   | tee {log error $in }
#   | error make {msg: $in }
# } else {
#   log info $"Creation complete! Ingress IP: ($ingress.ip)"
#   $config.ingress = $ingress
#   $config | save -f $config_path
#   kn get svc -n ingress-nginx 
# }
#
# # ##################################################
# # Create an A record
# # ##################################################
#
# mut $config = open $config_path
# mut $arecord = $config.arecord
# let rej = ["dns"]
#
# if (
#   $arecord
#     | reject ...$rej
#     | traspose key value
#     | any {|e| $e.value == null }
# ) {
#   $"Some configuration values are unset. Please set them in ($config_path)"
#     | tee {log error $in }
#     | error make {msg: $in }
# }
#
# nos recordset create \
#   $arecord.zone_name \
#   $config.cluster.name \
#   --type A \
#   --record $config.ingress.ip --ttl 3600
#
# # Book keeping
# $arecord.started = true
# $arecord.creation_time = date now
# $config.arecord = $arecord
# $config | save -f $config_path
#
# # Wait for the A record to finish creating and become ACTIVE. We check this via openstack CLI
# while not $arecord.ready and ((date now) - $arecord.creation_time) < $arecord.timeout {
#   $arecord.ready = (nos recordset show $arecord.zone_name $"($config.cluster.name).($arecord.zone_name)").status
#   | tee {log info $"[ Time elapsed ((date now) - $cluster.creation_time) ] Creation status: ($in)" }
#   | $in == "ACTIVE"
#   sleep 30sec;
# }
#
# if not $arecord.ready {
#   error make {msg: "A-Record did not create successfully! Aborting ..."}
# } else {
#   print $"$(ansi gb) A-Record created successfully!"
#   nos recordset list $ZONE_NAME
#     | where name == $"($K8S_CLUSTER_NAME).($ZONE_NAME)"
# }
#
# if not $arecord.ready {
#   "A-Record creation failed! Aborting ..."
#   | tee {log error $in }
#   | error make {msg: $in }
# } else {
#   $config.arecord.dns = $"($config.cluster.name).($arecord.zone_name)"
#   | str trim -rc "."
#   log info $"A-Record creation complete! ($arecord.dns)"
#   $config.arecord = $arecord
#   $config | save -f $config_path
# }
#
# # ##################################################
# # Cert-manager
# # ##################################################
#
# # Read or set cert-manager version
#
#
# # Wait for cert-manager pods to come online
# # TODO: implement timeout logic
# mut CERT_MANAGER_READY = false
# while not $CERT_MANAGER_READY {
#   sleep 10;
# }
#
# if not $CERT_MANAGER_READY {
#   error make {msg: "Cert Manager did not install successfully! Aborting ..."}
# } else {
#   print $"$(ansi gb) Cert Manager installed successfully! See: "
#   kn get pods -n cert-manager
# }
#
# # >>>>>>>>>>>>>>>>>>>>
#
# mut $config = open $config_path
# mut $cert_manager = $config.cert_manager
# let rej = []
#
# if (
#   $cert_manager
#     | reject ...$rej
#     | traspose key value
#     | any {|e| $e.value == null }
# ) {
#   $"Some configuration values are unset. Please set them in ($config_path)"
#     | tee {log error $in }
#     | error make {msg: $in }
# }
#
# # Apply manifest from github
# kubectl apply -f $"https://github.com/cert-manager/cert-manager/releases/download/($CERT_MANAGER_VERSION)/cert-manager.yaml"
#
# # Book keeping
# $cert_manager.started = true
# $cert_manager.creation_time = date now
# $config.cert_manager = $cert_manager
# $config | save -f $config_path
#
# # Wait for the A record to finish creating and become ACTIVE. We check this via openstack CLI
# while not $cert_manager.ready and ((date now) - $cert_manager.creation_time) < $cert_manager.timeout {
#   $cert_manager.ready = kn --full get pods -n cert-manager | all {|p| $p.status.phase == "Running"}
#   log info $"[ Time elapsed ((date now) - $cluster.creation_time) ] Some cert-manager pods are still not running ..."
#   sleep 30sec;
# }
#
# if not $cert_manager.ready {
#   "Cert-Manager installation failed! Aborting ..."
#   | tee {log error $in }
#   | error make {msg: $in }
# } else {
#   $config.cert_manager.dns = $"($config.cluster.name).($cert_manager.zone_name)"
#   | str trim -rc "."
#   log info $"Cert-Manager installation complete complete!"
#   $config.cert_manager = $cert_manager
#   $config | save -f $config_path
#   kn get pods -n cert-manager
# }
#
# # ##################################################
# # Install JHub
# # ##################################################
#
# # Read or set JHub settings in values.yaml
#
# # Check that "everything" in values.yaml is set appropriately
#
# helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
# helm repo update
#
# helm upgrade --install $JHUB_RELEASE jupyterhub/jupyterhub \
#       --namespace $JHUB_NAMESPACE  \
#       --create-namespace \
#       --version $JHUB_VERSION \
#       --debug \
#       --values config_standard_storage.yaml --values secrets.yaml
#
# # Wait for JHub to come online
#
# # Wait for certificate to become ready
#
# # ##################################################
# # Install Fluentbit
# # ##################################################
#
# # Do stuff
