FROM ubuntu:xenial-20210416

# Run a quick apt-get update/upgrade
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

# Install dependencies, mainly for SteamCMD
RUN apt-get install --no-install-recommends -y \
    ca-certificates \
    software-properties-common \
    python-software-properties \
    lib32gcc1 \
    xvfb \
    curl \
    wget \
    telnet \
    expect

# Run as root
USER root

# Setup the default timezone
ENV TZ=Europe/Helsinki
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create and set the steamcmd folder as a volume
RUN mkdir -p /steamcmd/conan
VOLUME ["/steamcmd/conan"]

# Add the steamcmd installation script
ADD install.txt /install.txt

# Copy scripts
ADD start_conan.sh /start.sh
ADD update_check.sh /update_check.sh

# Expose necessary ports
EXPOSE 27015/udp
EXPOSE 27016/udp

# Setup default environment variables for the server
ENV CONAN_EXILES_SERVER_STARTUP_ARGUMENTS "C:\conanserver\ConanSandbox\Binaries\Win64\ConanSandboxServer.exe" "ConanSandbox?Multihome=X.X.X.X?GameServerPort=27015?GameServerQueryPort=27016?ServerName=YOURSERVERNAME?MaxPlayers=20?listen?AdminPassword=YOURADMINPASSWORD"
ENV CONAN_EXILES_UPDATE_CHECKING "0"

# Start the server
ENTRYPOINT ["./start.sh"]
