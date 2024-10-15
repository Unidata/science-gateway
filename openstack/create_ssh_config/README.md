# Create SSH Config

This script will create a seperate SSH config file at
`$HOME/.ssh/openstack-config` that can be included in the standard SSH config
file.

## How it works

The script uses the `openstacksdk` to query JS2 for a list of all servers and
parse the result for any servers that have the `interface_ip` attribute, i.e. a
public ip.

Other server attributes are parsed and the `sshconf` python package applied to
create the `openstack-config` file. In addition to "normal" config entries, it
also creates entries that tunnel through the "gate" server, as well as the local
forwards.

***IMPORTANT***
One big assumption of this script is which user is used to log in to each
server. When Jetstream_Kubespray/Terraform creates servers, it actually attaches
some meta data that specifies the SSH user. This meta data is parsed to
determine the SSH user, if it exists, otherwise `rocky` is used as the SSH user.
If some mistake is made, you can always specify the login user on the CLI when
issuing the SSH command: `$ ssh user@host`.

## clouds.yaml

The script needs a valid `clouds.yaml` file in the standard location,
`$HOME/.config/openstack/clouds.yaml`. You may already have one, but you can
create a new one from [Jetstream2's Horizon
Dashboard](https://js2.jetstream-cloud.org/project/).

1) Log in
2) Use the side bar to navigate to "Identity --> Application Credentials"
3) Click "+ Create New Appllication Credential"
4) Fill out the required fields
5) Download the `clouds.yaml` file; *it's only available for download at this
point*!

## Conda Environment

Create the conda environment with `mamba`:

`mamba env update -f environment.yaml`

The new environment is created as `create_ssh_config`.

## Usage

Edit the script to specify the gate user (i.e. your UCAR username), the forward
port (which will be incremented to create a forward for each entry), and a key
file name.

Optionally, copy this script to your local bin directory:

`mkdir -p $HOME/.local/bin && cp create_ssh_config.py $HOME/.local/bin`

Make it executable:

`chmod u+x create_ssh_config.py`

Run from the command line. Note the hashbang `#!` at the start of the script
specifies that the script should be ran within the `conda` environment we
created.

`./create_ssh_config.py`

Verify the output

`cat $HOME/.ssh/openstack-config`

Ensure that this file is included in the standard SSH config file:

```
$ cat ~/.ssh/config
AddKeysToAgent yes

Include ~/.ssh/openstack-config

# ...

# Other non-openstack hosts
```

