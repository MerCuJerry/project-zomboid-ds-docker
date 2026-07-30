#!/bin/sh
# VARIABLES
export LD_LIBRARY_PATH=${STEAMAPPDIR}/jre64:$LD_LIBRARY_PATH
CONFIG_PATH=${STEAMAPPDIR}/ProjectZomboid64.json

su

if [ ! -z "$PUID" ] && [ "$PUID" != "$(id -u steam)" ]; then
    usermod -o -u "$PUID" steam
fi
if [ ! -z "$PGID" ] && [ "$PGID" != "$(id -g steam)" ]; then
    groupmod -o -g "$PGID" steam
fi

chown -R steam:steam /home/steam/

su steam

if ! test -d /home/steam/Zomboid/Server; then
    mkdir -p /home/steam/Zomboid/Server
    echo "COPY configuration from <${HOMEDIR}/Server/ZomboidDocker*> to </home/steam/Zomboid/Server/${SERVER_NAME}*>"
    if ! test -f /home/steam/Zomboid/Server/${SERVER_NAME}.ini; then
    cp ${HOMEDIR}/Server/ZomboidDocker.ini /home/steam/Zomboid/Server/${SERVER_NAME}.ini
    fi
    if ! test -f /home/steam/Zomboid/Server/${SERVER_NAME}_SandboxVars.lua; then
    cp ${HOMEDIR}/Server/ZomboidDocker_SandboxVars.lua /home/steam/Zomboid/Server/${SERVER_NAME}_SandboxVars.lua
    fi
    if ! test -f /home/steam/Zomboid/Server/${SERVER_NAME}_spawnpoints.lua; then
    cp ${HOMEDIR}/Server/ZomboidDocker_spawnpoints.lua /home/steam/Zomboid/Server/${SERVER_NAME}_spawnpoints.lua
    fi
    if ! test -f /home/steam/Zomboid/Server/${SERVER_NAME}_spawnregions.lua; then
    cp ${HOMEDIR}/Server/ZomboidDocker_spawnregions.lua /home/steam/Zomboid/Server/${SERVER_NAME}_spawnregions.lua
    fi
fi


# Steamcmd install
if [ "${SKIP_INSTALL}" == "false" ]; then
    echo "APP <ID:${STEAMAPPID}> Install directory will be ${STEAMAPPDIR}"
    if [ "${STEAM_TEST_BRANCH}" != "" ]; then
        echo "Using steamcmd beta branch ${STEAM_TEST_BRANCH}"
        ${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} -beta ${STEAM_TEST_BRANCH} validate +quit
    else
        echo "Using steamcmd default branch"
        ${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} validate +quit
    fi
fi

# Update config (will reset on each steamcmd update)
sed -i "s=Xmx8g=Xmx${CONFIG_XMX}g=g" ${CONFIG_PATH}
sed -i "s=UseZGC=UseG1GC=g" ${CONFIG_PATH}

${STEAMAPPDIR}/start-server.sh -servername ${SERVER_NAME} -adminpassword ${ADMIN_PASSWORD} ${ADDITIONAL_ARGS}