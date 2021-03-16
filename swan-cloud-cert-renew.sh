#!/bin/sh

# This script will try to renew the specified certificate for the server and apply it to the server by 
# restarting it. Assumes that certbot is installed and there is already a certificate setup for the server
# under the specified domain.

# get command line arguments
while [ $# -gt 0 ]
do
key="$1"

case $key in
    -d|--domain)
    DOMAIN="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

# Check required params and exit if not set
if [ -z "$DOMAIN" ] ; then
    echo "Must provide the domain that the server is currently under, with the -d|--domain flag." 1>&2
    exit 1
fi

# renew cert in the current path
certbot renew
openssl pkcs12 -export -out swancloudcert.p12 -in /etc/letsencrypt/live/${DOMAIN}/fullchain.pem -inkey /etc/letsencrypt/live/${DOMAIN}/privkey.pem -passout pass: -name "swancloud"
chmod +r swancloudcert.p12

# refresh the server
./swan-cloud-server-deploy.sh