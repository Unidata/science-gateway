FROM nginx:latest

MAINTAINER Unidata <support@unidata.ucar.edu>

RUN apt-get update && apt-get install -y --no-install-recommends openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /etc/nginx/certs/ && openssl dhparam 4096 > \
    /etc/nginx/certs/dhparam.pem

CMD ["nginx", "-g", "daemon off;"]
