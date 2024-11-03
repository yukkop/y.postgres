FROM postgres:15

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    gcc \
    git \
    gnupg \
    libssl-dev \
    llvm \
    lsb-release \
    make \
    pkg-config \
    wget

# Switch to postgres user
USER postgres

RUN wget -qO- https://sh.rustup.rs | \
  sh -s -- \
  -y \
  --profile minimal \
  --default-toolchain=1.72.0

RUN . "$HOME/.cargo/env" && \
  rustup toolchain install 1.72.0 && \
  rustup default 1.72.0 && \
  rustup component add rustc-dev

# Switch back to root to clean up
USER root

RUN wget -O /tmp/plrust.deb https://github.com/tcdi/plrust/releases/download/v1.2.8/plrust-trusted-1.2.8_1.72.0-debian-bullseye-pg15-amd64.deb
RUN chmod 644 /tmp/plrust.deb
#RUN dpkg -i /tmp/plrust.deb && apt-get install -f
RUN apt install -y /tmp/plrust.deb

# Clean up
RUN apt-get remove -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* $CARGO_HOME/registry $CARGO_HOME/git

# Copy initialization scripts, if any
#ADD ./initdb.sql /docker-entrypoint-initdb.d/

# Expose the PostgreSQL port
EXPOSE 5432
