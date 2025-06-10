#! /usr/bin/env nu

def main [
  num_of_users: int # Number of users to create
  prefix: string = "pyaos" # Users will be created as <prefix>-<hex>
  --print-values (-p) # In addition to printing as yaml, print users as plain text
  --file (-f): string = "" # Output yaml file
] {

  let allowed_users = (1..$num_of_users | each { || $"($prefix)-(random binary 2 | encode hex | str downcase)" })

  let hub_config = {
    hub: {
      config: {
        Authenticator: {
          allowed_users: $allowed_users
        }
      }
    }
  } | to yaml

  print $hub_config

  if ($file | is-not-empty) {
    $hub_config | save $file
  }

  if $print_values {
    $allowed_users | to text
  }

}
