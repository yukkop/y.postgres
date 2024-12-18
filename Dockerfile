FROM postgres:15

ARG INSTALL_PLRUST=false
ARG INSTALL_CRON=false
ARG INSTALL_HTTP=false
ARG INSTALL_JWT=false

ENV INSTALL_PLRUST=${INSTALL_PLRUST}
ENV INSTALL_CRON=${INSTALL_CRON}
ENV INSTALL_HTTP=${INSTALL_HTTP}
ENV INSTALL_JWT=${INSTALL_JWT}

USER root

# Base dependencies required for some installations
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

# Install cron if enabled
RUN if [ "$INSTALL_CRON" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-15-cron && \
    rm -rf /var/lib/apt/lists/*; \
  fi

# Install http if enabled
RUN if [ "$INSTALL_HTTP" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-15-http && \
    rm -rf /var/lib/apt/lists/*; \
  fi

# Install JWT if enabled
RUN if [ "$INSTALL_JWT" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends git make gcc pkg-config libssl-dev && \
    cd /tmp && \
    git clone https://github.com/michelp/pgjwt.git && \
    cd pgjwt && \
    make install && \
    cd / && \
    rm -rf /tmp/pgjwt && \
    apt-get remove -y git make gcc pkg-config libssl-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*; \
  fi

# Install PL/Rust if enabled
RUN if [ "$INSTALL_PLRUST" = "true" ]; then \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      clang \
      gnupg \
      llvm \
      lsb-release \
      && rm -rf /var/lib/apt/lists/*; \
  fi

USER postgres

RUN if [ "$INSTALL_PLRUST" = "true" ]; then \
    wget -qO- https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain=1.72.0 && \
    . "$HOME/.cargo/env" && \
    rustup toolchain install 1.72.0 && \
    rustup default 1.72.0 && \
    rustup component add rustc-dev; \
  fi

ENV PATH="/var/lib/postgresql/.cargo/bin:${PATH}"

USER root

RUN if [ "$INSTALL_PLRUST" = "true" ]; then \
    wget -O /tmp/plrust.deb https://github.com/tcdi/plrust/releases/download/v1.2.8/plrust-trusted-1.2.8_1.72.0-debian-bullseye-pg15-amd64.deb && \
    chmod 644 /tmp/plrust.deb && \
    apt install -y /tmp/plrust.deb && \
    rm /tmp/plrust.deb; \
  fi

# Clean up if PL/Rust is not installed
RUN if [ "$INSTALL_PLRUST" != "true" ]; then \
    apt-get clean && rm -rf /var/lib/apt/lists/*; \
  fi

# Copy initialization scripts
ADD ./src /docker-entrypoint-initdb.d
RUN chmod 755 /docker-entrypoint-initdb.d
RUN chmod 644 /docker-entrypoint-initdb.d/*.sql

ADD ./postgresql.conf /etc/postgresql/postgresql.conf
RUN chown 999:999 /etc/postgresql/postgresql.conf && \
    chmod 644 /etc/postgresql/postgresql.conf

ADD ./plugin/plrust/allowed-dependencies.toml /etc/postgresql/allowed-dependencies.toml
RUN chown 999:999 /etc/postgresql/allowed-dependencies.toml && \
    chmod 644 /etc/postgresql/allowed-dependencies.toml

RUN if [ "$INSTALL_PLRUST" = "true" ]; then \
    mkdir -p /var/lib/postgresql/plrust && \
    chown -R postgres:postgres /var/lib/postgresql/plrust; \
  fi

EXPOSE 5432
