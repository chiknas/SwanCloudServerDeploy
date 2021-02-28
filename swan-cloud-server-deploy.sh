#!/bin/sh
CONTAINER="swancloud"
IMAGE="chiknas/swancloud:latest"

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
    if docker rm $CONTAINER ; then
        echo "Removed container $CONTAINER"
    else
        echo "Unable to remove $CONTAINER. Exiting..."
        exit 1
    fi
fi

# refresh image
docker image rm $IMAGE
docker pull $IMAGE
echo "Refreshed image $IMAGE"

# deploy
echo "Starting deployment of $CONTAINER"
docker run -d \
-p 80:8080 \
-v "${HOSTPATH}":"/app/data" \
--env files.base-path=/app/data \
--env spring.profiles.active=production \
--env security.api.keys="{$APIKEYS}" \
--env server.ssl.enabled=false \
--name $CONTAINER \
$IMAGE