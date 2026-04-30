FROM node:24-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        make \
        g++ \
        python3 \
        gosu \
        sudo && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code t3 && \
    npm cache clean --force

ARG RUN_USER=t3user
ARG GRANT_SUDO=false
RUN if [ "${RUN_USER}" != "root" ]; then \
        useradd --create-home --shell /bin/bash "${RUN_USER}"; \
        if [ "${GRANT_SUDO}" = "true" ]; then \
            echo "${RUN_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
        fi; \
    fi

ENV RUN_USER=${RUN_USER}

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/${RUN_USER}

ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]
