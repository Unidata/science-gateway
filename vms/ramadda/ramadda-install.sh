#!/bin/bash
# Create RAMADDA default password

echo ramadda.install.password=changeme! | tee --append \
  /repository/pw.properties > /dev/null

mkdir -p ~/logs/ramadda-tomcat/
mkdir -p ~/logs/ramadda/

(crontab -l ; echo "59 0 * * * find ~/logs -regex '.*\.\(log\|txt\)' -type f -mtime +10 -exec rm -f {} \;")| crontab -
