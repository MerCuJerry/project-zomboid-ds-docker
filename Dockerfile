FROM cm2network/steamcmd:root

ENV CONFIG_XMX=16
ENV SERVER_NAME=ZomboidDocker
ENV ADMIN_PASSWORD=ZomboidDockerAdmin
ENV STEAM_TEST_BRANCH=""
ENV ADDITIONAL_ARGS=""
ENV SKIP_INSTALL=false

ENV STEAMAPPID=380870
ENV STEAMAPP=project-zomboid
ENV STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-dedicated"

ENV PUID=1001
ENV PGID=1001

# ARG DEBIAN_FRONTEND=noninteractive

COPY entrypoint.sh ${HOMEDIR}/entrypoint.sh
RUN chmod +x "${HOMEDIR}/entrypoint.sh"

RUN useradd -g ${PGID} -u ${PUID} Zomboid

RUN chown -R ${PUID}:${PGID} "${HOMEDIR}"
USER Zomboid

COPY Server ${HOMEDIR}/Server
WORKDIR ${HOMEDIR}
VOLUME ${STEAMAPPDIR}

CMD ["bash", "entrypoint.sh"]

EXPOSE 16261/udp
EXPOSE 16262/udp