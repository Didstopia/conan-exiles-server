# NOTE: Does *NOT* work yet due to Conan Exiles not having a valid linux dedicated server yet!

## Conan Exiles server that runs inside a Docker container

NOTE: This image will always install/update to the latest steamcmd and 7 Days to Die server, all you have to do to update your server is to redeploy the container.

Also note that the entire /steamcmd/conan can be mounted on the host system.

# How to run the server
1. Set the ```CONAN_EXILES_SERVER_STARTUP_ARGUMENTS``` environment variable to match your preferred server arguments (defaults can be found inside `Dockerfile`)
2. Optionally mount ```/steamcmd/conan``` somewhere on the host or inside another container to keep your data safe
3. Run the container and enjoy!

One additional feature you can enable is fully automatic updates, meaning that once a server update hits Steam, it'll restart the server and trigger the automatic update. You can enable this by setting ```SEVEN_DAYS_TO_DIE_UPDATE_CHECKING``` to ```"1"```.