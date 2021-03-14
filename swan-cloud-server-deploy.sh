#!/bin/sh
CONTAINER="swancloud"
IMAGE="chiknas/swancloud"

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
if [ -z "$SSL" ] ; then
    SSL=false
fi

# Use latest if image tag is not provided
if [ -z "$TAG" ] ; then
    IMAGE="${IMAGE}:latest"
else
    IMAGE="${IMAGE}:${TAG}"
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
if $SSL ; then
    IMAGE="swancloudsecure"
    docker image rm $IMAGE
    docker build --tag $IMAGE:$TAG
else
    docker image rm $IMAGE
    docker pull $IMAGE
fi
echo "Refreshed image $IMAGE"

# deploy
echo "Starting deployment of $CONTAINER"
docker run -d --restart always \
-p 80:8080 \
-v "${HOSTPATH}":"/app/data" \
--env files.base-path=/app/data \
--env spring.profiles.active=production \
--env security.api.keys="{$APIKEYS}" \
--env server.ssl.enabled="{$SSL}" \
--name $CONTAINER \
$IMAGE:$TAG