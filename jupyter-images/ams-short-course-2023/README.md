# MetPy AMS 2023 Shortcourse

Dockerfile and other necessary files for running the JupyterHub instance
deployed for Unidata's MetPy Shortcourse at the 2023 AMS conference.

Environment file is fetched from the
[unidata/metpy-ams-2023](https://github.com/Unidata/metpy-ams-2023) repository
when building the image.

Before building the image, copy the `Acknowledgements.ipynb` notebook to this
directory.

This image is built following the instructions in this repo under
`vms/jupyter/readme.md` with the image name `unidata/metpy-sc-ams-2023`.

### Authentication

Usually we employ a GitHub OAuth app to provide authentication for our
JupyterHubs. However, for exceptionally short-lived JHubs such as this one, it
can be useful to instead use "dummy authentication." This way, instead of
needing participants to send us their GitHub information prior to the workshop,
we can create credentials for them.  Participants will be given a slip of paper
with their credentials for the course.

To create these credentials, execute the following:

```shell
#! /bin/bash

# Start with a fresh set of users
rm /tmp/rand

# Create password
PASS=$(openssl rand -hex 10)
or
# PASS="supersecretpassword"

let NUM_OF_USERS=60

# Create users; the leading dash is for easy copy/paste into our JHub config
for i in $(seq 1 $NUM_OF_USERS); do echo "- ams-$(openssl rand -hex 2)" >> /tmp/rand; done

# Parse the file into a pretty format that can be read into a spreadsheet for
# printing
URL=<URL>
sed -E -e "s|- (.*)|\"$URL\r\nuser: \1\r\npassword: $PASS\"|g" rand > /tmp/rand.csv
```
