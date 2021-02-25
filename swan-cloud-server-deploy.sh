#!/bin/sh
container="swancloud"
apiKeys=
hostPath=

# clear container
docker stop $container
docker rm $container

# refresh image
docker pull chiknas/swancloud:latest

# deploy
docker run \
-p 8080:8080 \
-v "${hostPath}":"/app/data" \
--env files.base-path=/app/data \
--env spring.profiles.active=production \
--env security.api.keys="{'$apiKeys'}" \
--env server.ssl.enabled=false \
--name $container \
chiknas/swancloud:latest