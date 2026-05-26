FROM --platform=amd64 didstopia/base:wine-steamcmd-ubuntu-24.04

LABEL maintainer="Didstopia <support@didstopia.com>"

# Fixes apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Conan Exiles has no native Linux dedicated server, so it runs as the Windows
# build under Wine + Xvfb. Wine, Xvfb, winbind, winetricks and the 32-bit
# GL/Vulkan libraries all come from the wine-steamcmd base now, so only the
# extras specific to this image are installed here.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      telnet \
      expect && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup the default timezone
ENV TZ=Europe/Helsinki
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create the steamcmd folder
RUN mkdir -p /steamcmd/conan

# Add the steamcmd installation script + server scripts
ADD install.txt /install.txt
ADD start_conan.sh /start.sh
ADD update_check.sh /update_check.sh
RUN chmod +x /start.sh /update_check.sh

# Fix permissions (SteamCMD content + the Wine prefix must be writable at runtime)
RUN chown -R 1000:1000 /steamcmd /app

# Run as a non-root user by default
ENV PGID 1000
ENV PUID 1000

# Expose necessary ports
EXPOSE 7777/udp
EXPOSE 7778/udp
EXPOSE 27015/udp

# Setup default environment variables for the server
ENV CONAN_EXILES_SERVER_NAME "Conan Exiles (Docker)"
ENV CONAN_EXILES_SERVER_PASSWORD ""
ENV CONAN_EXILES_ADMIN_PASSWORD ""
ENV CONAN_EXILES_MAX_PLAYERS "40"
ENV CONAN_EXILES_GAME_PORT "7777"
ENV CONAN_EXILES_QUERY_PORT "27015"
ENV CONAN_EXILES_UPDATE_CHECKING "0"

# Expose the volumes (game files + the Wine prefix, which the base puts at /app/wine)
VOLUME ["/steamcmd/conan", "/app/wine"]

# Start the server
CMD [ "bash", "/start.sh" ]
