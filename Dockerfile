# Use official PostgreSQL image as base
ARG PG_VERSION=16
FROM postgres:${PG_VERSION}

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    postgresql-server-dev-${PG_MAJOR} \
    && rm -rf /var/lib/apt/lists/*

# Clone and build pg_ttl_index extension
WORKDIR /tmp
RUN git clone https://github.com/ibrahimkarimeddin/postgres-extensions-pg_ttl.git && \
    cd postgres-extensions-pg_ttl && \
    make && \
    make install && \
    cd .. && \
    rm -rf postgres-extensions-pg_ttl

# Add pg_ttl_index to shared_preload_libraries
RUN echo "shared_preload_libraries = 'pg_ttl_index'" >> /usr/share/postgresql/postgresql.conf.sample

# Clean up build dependencies to reduce image size
RUN apt-get purge -y --auto-remove \
    build-essential \
    git \
    postgresql-server-dev-${PG_MAJOR}

WORKDIR /

# The postgres image already has the correct ENTRYPOINT and CMD
