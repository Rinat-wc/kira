# (rm -fv $KIRA_INFRA/docker/validator/Dockerfile) && nano $KIRA_INFRA/docker/validator/Dockerfile
FROM registry.local:5000/base-image:latest

ARG BUILD_HASH
ARG BRANCH
ARG REPO

RUN echo "Build hash: ${BUILD_HASH}"

RUN mkdir ${SEKAI} -p
RUN cd ${GOPATH}/src/github.com/kiracore && git clone ${REPO}
RUN cd ${SEKAI} && git checkout ${BRANCH}
RUN mkdir -p "${COMMON_DIR}"

ADD ./container ${SELF_CONTAINER}

RUN chmod 777 -R ${SELF_HOME}

ARG DEBIAN_FRONTEND=noninteractive

RUN printenv

EXPOSE 11000

HEALTHCHECK --interval=60s --timeout=600s --start-period=180s --retries=2 CMD ${HEALTHCHECK_SCRIPT} $>> ${SELF_LOGS}/healthcheck_script_output.txt

CMD ["sh", "-c", "/bin/bash ${START_SCRIPT}"]
