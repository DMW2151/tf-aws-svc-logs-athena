#! /bin/sh

# A very(!) simple echo container running in Docker
docker pull jmalloc/echo-server &&\
    docker run -d -p 8080:8080 jmalloc/echo-server
