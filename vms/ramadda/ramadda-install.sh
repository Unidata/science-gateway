#!/bin/bash
# Create RAMADDA default password

echo ramadda.install.password=changeme! | tee --append \
  /repository/pw.properties > /dev/null

mkdir -p /logs/ramadda-tomcat/
mkdir -p /logs/ramadda/
