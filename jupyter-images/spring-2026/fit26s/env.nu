# FILE: env.nu
# Configuration for jupyterhub cluster deployment
# Anything with a "SET ME!" comment *must* be set

$env.jupyterhub.cluster = {
  template: "kubernetes-1-30-jammy",
  master: {count: 1, flavor: "m3.quad"},
  worker: {count: 1, flavor: "m3.quad"},
  autoscaling: "true",
  name: fit26s, # SET ME!
  existing_ip: null # If set to something other than "null", attempt to use this IP when creating the ingress loadBalancer service
}

$env.jupyterhub.nodegroup = {
  name: "mediums",
  flavor: "m3.medium",
  autoscaling: true,
  max_nodes: 4 # SET ME!
}

$env.jupyterhub.zone = "ees220002.projects.jetstream-cloud.org."

$env.jupyterhub.shared_volume = {
  user_quota: 10, # Storage per user
  home_size: 150, # Total size of home dir volume, accounting for all users; In GB; if this is left null, users will not have persistent storage
  data_size: 20, # Total size of /share mount, in GB; if this is left null, no additional storage is allocated for shared data
  values_path: "./shared-user-volume/values-nfs.yaml",
  pv_path: "./shared-user-volume/pv.yaml",
  pvc_path: "./shared-user-volume/pvc.yaml",
  job_path: "./shared-user-volume/init-shared-dir.yaml"
}

# Secrets for Dockerhub authentication, JupyterHub, and authentication secrets
$env.jupyterhub.dockerhub = "./jhub/dockerhub.yaml"
$env.jupyterhub.secrets = "./jhub/secrets.yaml"
$env.jupyterhub.authentication = "./jhub/authentication.yaml"

# Used to create jhub's values.yaml
$env.jupyterhub.jhub = {
  values_path: ./jhub/values.yaml,
  admins: [], # E.g. [ admin1 admin2 admin3 ]; Unidata admins added automatically, putting them here is unnecessary
  image_name: null, # String: Defaults to unidata/$env.jupyterhub.cluster.name if kept `null` here
  image_tag: null, # String: SET ME!
  # git_repos: [ # List of records; change to `[]` if no git_repos are requested
  #   {
  #     server: null, # String: Defaults to https://github.com
  #     user: null, # SET ME!
  #     repo: null, # SET ME!
  #     branch: null, # String: Defaults to "main"
  #     dest_dir: null # Defaults to repo name if kept `null` here
  #   },
  # ]
  user_placeholders: null, # Change to `null` to disable user_placeholders
  desired_profiles: [Low IDV] # Choose from: [Low Standard Medium High IDV]
  default_profile: "Low" # Choose from the list in "desired_profiles" above
}
