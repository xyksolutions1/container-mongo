# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG \
    BASE_IMAGE

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="Mongo" \
        org.opencontainers.image.description="Key Value store" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/mongodb" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-mongodb/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-mongodb.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    MONGO_VERSION="r7.0.28" \
    MONGO_REPO_URL="https://github.com/mongodb/mongo" \
    MONGOSHELL_VERSION="2.5.10" \
    MONGOSHELL_REPO_URL="https://github.com/mongodb-js/mongosh" \
    MONGOTOOLS_VERSION="master" \
    MONGOTOOLS_REPO_URL="https://github.com/mongodb/mongo-tools"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    CONTAINER_ENABLE_SCHEDULING=TRUE \
    IMAGE_NAME="nfrastack/mongo" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-mongo/"

EXPOSE \
       27017 \
       28017

RUN echo "" && \
    MONGO_BUILD_DEPS_DEBIAN=" \
                                build-essential \
                                git \
                                libcurl4-openssl-dev \
                                liblzma-dev \
                                libkrb5-dev \
                                libssl-dev \
                                lsb-release \
                                python3-dev \
                                python3-pip \
                            " \
                            && \
    \
    MONGO_RUN_DEPS_DEBIAN=" \
                            nodejs \
                            " \
                            && \
    \
    source /container/base/functions/container/build && \
    container_build_log image && \
    create_user mongo 27017 mongo 27017 /dev/null && \
    package repo add node 22 && \
    package update && \
    package upgrade && \
    package build go && \
    package install \
                        MONGO_BUILD_DEPS \
                        MONGO_RUN_DEPS \
                        && \
    \
    clone_git_repo "${MONGOTOOLS_REPO_URL}" "${MONGOTOOLS_VERSION}" && \
    ./make build && \
    strip bin/mongo* && \
    mv bin/* /usr/local/sbin && \
    container_build_log add "Mongo Tools" "${MONGOTOOLS_VERSION}" "${MONGOTOOLS_REPO_URL}" && \
    \
    npm install -g mongosh@${MONGOSHELL_VERSION/v/} && \
    container_build_log add "Mongo Shell" "${MONGOSHELL_VERSION}" "npm" && \
    clone_git_repo "${MONGO_REPO_URL}" "${MONGO_VERSION}" && \
    \
    source /container/base/functions/container/build && \
    pip install --break-system-packages uv && \
    uv venv /usr/src/mongo-build && \
    source /usr/src/mongo-build/bin/activate && \
    cd /usr/src/mongo && \
    uv pip install \
                    -r /usr/src/mongo/etc/pip/compile-requirements.txt \
                    && \
    python3 buildscripts/scons.py \
                                    install-devcore \
                                        --disable-warnings-as-errors \
                                        --linker=gold \
                                        -j$(( $(nproc) - 1 )) \
                                        && \
    strip build/install/bin/mongo* && \
    mv \
            build/install/bin/mongo* \
        /usr/local/bin/ && \
    container_build_log add "Mongo DB" "${MONGO_VERSION}" "${MONGO_REPO_URL}" && \
    package remove \
                    MONGO_BUILD_DEPS \
                    && \
    package cleanup

COPY rootfs /
