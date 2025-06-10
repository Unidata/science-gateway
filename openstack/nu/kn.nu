$env.KN_PREVIOUS_OUTPUT = []

# Kubectl with Nu commands
def kn [] { ignore }

# wrapper for `kubectl get ...`
# Output of the get command is piped into `detect columns`
def --env --wrapped "kn get" [
  --full (-f) # Capture the full output as yaml, e.g. `kubectl get pods -o yaml`
  ...rest
]: any -> table {

  let flags = if $full {$rest | append ["-o" "yaml"]} else { $rest }
  let result = kubectl get ...$flags | complete

  if $result.exit_code != 0 { print $result; return }

  if $full {
    $env.KN_PREVIOUS_OUTPUT = $result.stdout | from yaml
    $env.KN_PREVIOUS_OUTPUT
  } else {
    $env.KN_PREVIOUS_OUTPUT = $result.stdout | detect columns --guess
    $env.KN_PREVIOUS_OUTPUT
  }
}

# Show the output of the previous "kn" command
def --env "kn prev" []: any -> table {
  $env.KN_PREVIOUS_OUTPUT
}
