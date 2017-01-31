#!/bin/bash

./docker_build.sh

docker tag didstopia/conan-exiles-server:latest didstopia/conan-exiles-server:latest
docker push didstopia/conan-exiles-server:latest