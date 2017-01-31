#!/bin/bash

./docker_build.sh

## TODO: Update checking seems to be broken, fix it

# Run the server
docker run -p 27015:27015/udp -p 27016:27016/udp -e CONAN_EXILES_UPDATE_CHECKING="0" -v $(pwd)/conan_data:/steamcmd/conan --name conan-exiles-server -d didstopia/conan-exiles-server:latest
docker logs -f conan-exiles-server
