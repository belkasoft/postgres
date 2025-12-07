# Use official PostgreSQL image as base
ARG PG_VERSION=16
FROM postgres:${PG_VERSION}

# Install pgxn client and pg_ttl_index extension, then clean up
WORKDIR /tmp
RUN apt-get update && apt-get install -y --no-install-recommends \
    pgxnclient \
    postgresql-server-dev-"${PG_MAJOR}" \
    build-essential \
    && pgxn install pg_ttl_index \
    && echo "shared_preload_libraries = 'pg_ttl_index'" >> /usr/share/postgresql/postgresql.conf.sample \
    && apt-get purge -y --auto-remove \
        pgxnclient \
        build-essential \
        postgresql-server-dev-"${PG_MAJOR}" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

# The postgres image already has the correct ENTRYPOINT and CMD
