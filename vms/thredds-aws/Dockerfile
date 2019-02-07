FROM unidata/thredds-docker:latest

MAINTAINER Unidata THREDDS <support-thredds@unidata.ucar.edu>

# s3fs-libs.tar.bz2 is available from the Unidata/TdsConfig project
COPY s3fs-libs.tar.bz2 /usr/local/tomcat

WORKDIR /usr/local/tomcat

RUN tar -xjf s3fs-libs.tar.bz2

###
# Inherited from parent container
###

ENTRYPOINT ["/entrypoint.sh"]

###
# Start container
###

CMD ["catalina.sh", "run"]
