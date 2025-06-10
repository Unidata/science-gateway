$env.NOS_PREVIOUS_OUTPUT = []

# Nu OpenStack commands, uses the -f yaml to have nu parse the output
def --env --wrapped nos [...rest] {
  let result = openstack ...$rest -f yaml | complete
  if $result.exit_code != 0 {print $result; return}

  $env.NOS_PREVIOUS_OUTPUT = $result.stdout | from yaml
  $env.NOS_PREVIOUS_OUTPUT
}

# Show the output for the previous "nos" command
def "nos prev" []: any -> table {
  $env.NOS_PREVIOUS_OUTPUT
}

# openstack floating ip list
def --env "nos ofl" []: any -> table {
  nos floating ip list
}

# openstack floating ip create public
def --env "nos ofc" []: any -> table {
  nos floating ip create public
}

# openstack server list
def --env "nos osl" []: any -> table {
  nos server list
}

# openstack network list
def --env "nos onl" []: any -> table {
  nos network list
}

# openstack volume list
def --env "nos ovl" []: any -> table {
  nos volume list
}

# openstack server show
def --env "nos oss" [
  server: string # The server to show
]: any -> table {
  nos server show $server
}

# openstack volume show
def --env "nos ovs" [
  volume: string # The volume to show
]: any -> table {
  nos volume show $volume
}
