#!/bin/sh

# This script will deploy the server in unsecure mode and in secure mode if -s tag is applied. 
# If there are instances of the server running with the same image or container name they will be refreshed.

CONTAINER="swancloud"
TAG="latest"
SSL=false

# get command line arguments
while [ $# -gt 0 ]
do
key="$1"

case $key in
    -k|--keys)
    APIKEYS="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--path)
    HOSTPATH="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--tag)
    TAG="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--ssl)
    SSL=true
    shift # past argument
    ;;
    -d|--domain)
    DOMAIN="$2"
    shift # past argument
    shift # past value
    ;;
    -db|--db-path)
    DATABASEPATH="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

# Check required params and exit if not set
if [ -z "$APIKEYS" ] ; then
    echo "Must provide some known API keys to the environment with the -k|--keys flag." 1>&2
    exit 1
fi
if [ -z "$HOSTPATH" ] ; then
    echo "Must provide a host path to be used for storage with the -p|--path flag." 1>&2
    exit 1
fi
if [ "$SSL" = true ] ; then
    if [ -z "$DOMAIN" ] ; then
        echo "Must provide the current domain the server is running on with the -p|--path flag if we are in SSL mode." 1>&2
        exit 1
    fi
fi

# refresh image
if [ "$SSL" = true ] ; then
    # refresh certificate if we are in SSL mode
    certbot renew
    openssl pkcs12 -export -out swancloudcert.p12 -in /etc/letsencrypt/live/${DOMAIN}/fullchain.pem -inkey /etc/letsencrypt/live/${DOMAIN}/privkey.pem -passout pass: -name "swancloud"
    chmod +r swancloudcert.p12

    IMAGE="swancloudsecure:${TAG}"
    docker pull "chiknas/swancloud:${TAG}"
    docker build --tag $IMAGE .
    PORT=443
else
    IMAGE="chiknas/swancloud:${TAG}"
    docker pull $IMAGE
    PORT=80
fi
echo "Refreshed image $IMAGE"

# check docker container exists by trying to inspect it
if docker inspect $CONTAINER ; then

    # stop container if its running
    if docker inspect --format '{{json .State.Running}}' $CONTAINER ; then
        if docker stop $CONTAINER ; then
            echo "Stopped container $CONTAINER"
        else
            echo "Unable to stop $CONTAINER. Exiting..."
            exit 1
        fi
    fi

    # remove container
    docker rm $CONTAINER
fi

# deploy
echo "Starting deployment of $CONTAINER"
docker run -d --restart always \
-p $PORT:8080 \
-v "${HOSTPATH}":"/app/data" \
${DATABASEPATH:+-v "$DATABASEPATH":"/app/db"} \
--env files.base-path=/app/data \
--env spring.profiles.active=production \
--env security.api.keys="{$APIKEYS}" \
--env server.ssl.enabled=$SSL \
--name $CONTAINER \
$IMAGE

# clean up dangling images
docker image prune -f