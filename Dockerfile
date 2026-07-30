FROM cm2network/steamcmd:root

ENV CONFIG_XMX 16
ENV SERVER_NAME ZomboidDocker
ENV ADMIN_PASSWORD ZomboidDockerAdmin
ENV STEAM_TEST_BRANCH ""
ENV ADDITIONAL_ARGS ""
ENV SKIP_INSTALL false

ENV STEAMAPPID 380870
ENV STEAMAPP project-zomboid
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"

# ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt upgrade -y && \
    mkdir -p /usr/share/man/man1 && \
    apt-get install -y \
        libsdl2-2.0-0 \
        default-jre 

COPY entrypoint.sh ${HOMEDIR}/entrypoint.sh
COPY Server ${HOMEDIR}/Server
RUN chmod +x "${HOMEDIR}/entrypoint.sh" && chown -R "${USER}:${USER}" "${HOMEDIR}"

USER ${USER}
WORKDIR ${HOMEDIR}
VOLUME ${STEAMAPPDIR}

CMD ["bash", "entrypoint.sh"]

EXPOSE 16261/udp
EXPOSE 16262/udp