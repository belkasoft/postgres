# Use official PostgreSQL image as base
ARG PG_VERSION=16
FROM postgres:${PG_VERSION}

# Install build dependencies, build extension, and clean up in a single layer
WORKDIR /tmp
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    postgresql-server-dev-"${PG_MAJOR}" \
    && git clone https://github.com/ibrahimkarimeddin/postgres-extensions-pg_ttl.git \
    && cd postgres-extensions-pg_ttl \
    && make \
    && make install \
    && cd .. \
    && rm -rf postgres-extensions-pg_ttl \
    && echo "shared_preload_libraries = 'pg_ttl_index'" >> /usr/share/postgresql/postgresql.conf.sample \
    && apt-get purge -y --auto-remove \
        build-essential \
        git \
        postgresql-server-dev-"${PG_MAJOR}" \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

# The postgres image already has the correct ENTRYPOINT and CMD
