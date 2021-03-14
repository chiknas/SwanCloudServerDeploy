FROM chiknas/swancloud:arm32v7
RUN mkdir cert
COPY swancloudcert.p12 /cert
ENV server.ssl.key-store=/cert/swancloudcert.p12
ENV server.ssl.key-alias=swancloud