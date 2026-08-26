######
# Begin NBGallery Integration Config
######

import os

nbgallery_url = os.environ.get(
    "NBGALLERY_URL",
    "https://nbgallery.ees220002.projects.jetstream-cloud.org",
).rstrip("/")

# CORS + credentialed requests are required for NBGallery "Run in Jupyter".
c.ServerApp.allow_origin = nbgallery_url
c.ServerApp.allow_credentials = True
c.ServerApp.disable_check_xsrf = True

# Compatibility with older notebook-based servers.
c.NotebookApp.allow_origin = nbgallery_url
c.NotebookApp.allow_credentials = True
c.NotebookApp.disable_check_xsrf = True

######
# End NBGallery Integration Config
######
