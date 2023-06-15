# JupyterHub Configuration for AMS 2023 Student Python Workshop

A few notes on this configuration:

- This Docker build is mostly self-contained with the exception of the `environment.yml` which is fetched from the [Unidata/pyaos-ams-2023](http://github.com/Unidata/pyaos-ams-2023) repository.
- `secrets.yaml` contains the JupyterHub configuration with the exception of
  - secret or unique identifiers
  - user names
  - admins
  - docker image tags

Some notes on user authentication for this Hub. We normally use GitHub OAuth for our JupyterHubs, but for this in person workshop, we will likely use "dummy" authentication where we will literally hand out usernames and passwords on little sheets of paper as students walk in the room. In my experience, this is the fastest way to onboard users in a workshop where time is extremely limited. Many students will not have obtained a GitHub username beforehand and they will have to sign up during the workshop losing precious time. Here is a handy little script for generating random users:

```sh
for i in {1..200}
do
  echo "- ams-$(openssl rand -hex 2)" >> /tmp/rand
done
```

You can insert those users under the `allowed_users` key.

The `env.sh` is a convenience script for altering notebook metadata so the user is dropped into the correct conda environment when opening the notebook. You will need `jq` installed.

Copy `Acknowledgements.ipynb`, required for the Docker build, from the parent directory to this directory. For some reason, Docker builds do not let you copy files from parent directories.
