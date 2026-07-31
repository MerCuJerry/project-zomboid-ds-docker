#!/bin/sh
# VARIABLES
export LD_LIBRARY_PATH=${STEAMAPPDIR}/jre64:$LD_LIBRARY_PATH
CONFIG_PATH=${STEAMAPPDIR}/ProjectZomboid64.json

if [ ! -z "$PUID" ] && [ "$PUID" != "$(id -u steam)" ]; then
    usermod -o -u "$PUID" steam
fi
if [ ! -z "$PGID" ] && [ "$PGID" != "$(id -g steam)" ]; then
    groupmod -o -g "$PGID" steam
fi

chown -R steam:steam ${HOMEDIR}

su - steam
export HOME=${HOMEDIR}

if ! test -d ${HOMEDIR}/Zomboid/Server; then
    mkdir -p ${HOMEDIR}/Zomboid/Server
    echo "COPY configuration from <${HOMEDIR}/Server/ZomboidDocker*> to <${HOMEDIR}/Zomboid/Server/${SERVER_NAME}*>"
    if ! test -f ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}.ini; then
    cp ${HOMEDIR}/Server/ZomboidDocker.ini ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}.ini
    fi
    if ! test -f ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}_SandboxVars.lua; then
    cp ${HOMEDIR}/Server/ZomboidDocker_SandboxVars.lua ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}_SandboxVars.lua
    fi
    if ! test -f ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}_spawnpoints.lua; then
    cp ${HOMEDIR}/Server/ZomboidDocker_spawnpoints.lua ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}_spawnpoints.lua
    fi
    if ! test -f ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}_spawnregions.lua; then
    cp ${HOMEDIR}/Server/ZomboidDocker_spawnregions.lua ${HOMEDIR}/Zomboid/Server/${SERVER_NAME}_spawnregions.lua
    fi
fi


# Steamcmd install
if [ "${SKIP_INSTALL}" == "false" ]; then
    echo "APP <ID:${STEAMAPPID}> Install directory will be ${STEAMAPPDIR}"
    if [ "${STEAM_TEST_BRANCH}" != "" ]; then
        echo "Using steamcmd beta branch ${STEAM_TEST_BRANCH}"
        su - steam -c "${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} -beta ${STEAM_TEST_BRANCH} validate +quit"
    else
        echo "Using steamcmd default branch"
        su - steam -c "${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${STEAMAPPDIR} +login anonymous +app_update ${STEAMAPPID} validate +quit"
    fi
fi

# Update config (will reset on each steamcmd update)
sed -i "s=Xmx8g=Xmx${CONFIG_XMX}g=g" ${CONFIG_PATH}
sed -i "s=UseZGC=UseG1GC=g" ${CONFIG_PATH}

export HOME=${HOMEDIR}
su - steam -c "${STEAMAPPDIR}/start-server.sh -servername ${SERVER_NAME} -adminpassword ${ADMIN_PASSWORD} ${ADDITIONAL_ARGS}"