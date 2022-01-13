#! /bin/sh

# A very(!) simple echo container running in Docker
docker pull jmalloc/echo-server &&\
    docker run -p 8080:8080 jmalloc/echo-server -d