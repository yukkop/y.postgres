FROM postgres:15

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    clang \
    cmake \
    git \
    pkg-config \
    libpq-dev \
    llvm \
    curl \
    ca-certificates \
    openssl \
    zlib1g-dev \
    make \
    postgresql-server-dev-15

# Set environment variables for Rust installation
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH="$CARGO_HOME/bin:${PATH}"

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y \
    --no-modify-path \
    --default-toolchain 1.72.0 \
    --profile default

RUN cargo --version

# Install cargo-pgx
RUN cargo install cargo-pgrx --version 0.11.0 --locked

# Set PGRX_HOME to /var/lib/postgresql/.pgx
ENV PGRX_HOME="/var/lib/postgresql/.pgx"

# Change owner of necessary directories to postgres user
RUN mkdir -p ${PGRX_HOME} && \
    chown -R postgres:postgres ${PGRX_HOME} /usr/local/rustup /usr/local/cargo

# Clone the PL/Rust repository as root
RUN git clone https://github.com/tcdi/plrust.git /plrust

# Change ownership of the repository to postgres user
RUN chown -R postgres:postgres /plrust

# Switch to postgres user
USER postgres

# Ensure PATH is updated for postgres user
ENV PATH="$CARGO_HOME/bin:${PATH}"

# Initialize cargo-pgx for PostgreSQL 15
RUN cargo pgrx init --pg15 $(which pg_config)

# Build PL/Rust
WORKDIR /plrust/plrustc
RUN bash ./build.sh && cp ../build/bin/plrustc $CARGO_HOME/bin

WORKDIR /plrust/plrust/plrust

RUN cargo --version

# Build and install PL/Rust
RUN cargo pgrx run pg15 --release

# Switch back to root to clean up
USER root

# Clean up
RUN apt-get remove -y git && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* $CARGO_HOME/registry $CARGO_HOME/git

# Copy initialization scripts, if any
ADD ./initdb.sql /docker-entrypoint-initdb.d/

# Expose the PostgreSQL port
EXPOSE 5432
