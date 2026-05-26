#!/usr/bin/env bash

child=0

trap 'exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM
exit_handler()
{
	echo "Shut down signal received.."
	sleep 1
	kill $child 2>/dev/null
	exit
}

# Install/update steamcmd
echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | tar -v -C /steamcmd -zx

# Install/update Conan Exiles (the Windows build) from install.txt
echo "Installing/updating Conan Exiles.. (this might take a while, be patient)"
bash /steamcmd/steamcmd.sh +runscript /install.txt

# Initialise the Wine prefix on first boot (the prefix lives on a volume)
if [ ! -d "${WINEPREFIX}/drive_c" ]; then
	echo "Initialising Wine prefix.."
	xvfb-run --auto-servernum sh -c "wineboot --init && wineserver -w"
fi

# Install the VC++ runtime once (Conan's Unreal build needs it)
if [ ! -f "${WINEPREFIX}/.vcrun_installed" ]; then
	echo "Installing Visual C++ runtime into the Wine prefix.."
	xvfb-run --auto-servernum sh -c "winetricks -q vcrun2022 && wineserver -w" && \
		touch "${WINEPREFIX}/.vcrun_installed"
fi

# Run the update check if it's not been run before
if [ "${CONAN_EXILES_UPDATE_CHECKING}" == "1" ]; then
	if [ ! -f "/steamcmd/conan/build.id" ]; then
		./update_check.sh
	else
		OLD_BUILDID="$(cat /steamcmd/conan/build.id)"
		STRING_SIZE=${#OLD_BUILDID}
		if [ "$STRING_SIZE" -lt "6" ]; then
			./update_check.sh
		fi
	fi
fi

# Build the server startup arguments
SERVER_ARGS="ConanSandbox?GameServerPort=${CONAN_EXILES_GAME_PORT}?GameServerQueryPort=${CONAN_EXILES_QUERY_PORT}?ServerName=${CONAN_EXILES_SERVER_NAME}?MaxPlayers=${CONAN_EXILES_MAX_PLAYERS}?listen"
if [ -n "${CONAN_EXILES_SERVER_PASSWORD}" ]; then
	SERVER_ARGS="${SERVER_ARGS}?ServerPassword=${CONAN_EXILES_SERVER_PASSWORD}"
fi
if [ -n "${CONAN_EXILES_ADMIN_PASSWORD}" ]; then
	SERVER_ARGS="${SERVER_ARGS}?AdminPassword=${CONAN_EXILES_ADMIN_PASSWORD}"
fi

# Set the working directory to the game files
cd /steamcmd/conan || exit 1

# Run the server (Windows build under Wine, headless via Xvfb)
echo "Starting Conan Exiles.."
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' \
	wine ConanSandboxServer.exe "${SERVER_ARGS}" -nosteamclient -game -server -log &

child=$!
wait "$child"
