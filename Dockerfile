# Use official PostgreSQL image as base
ARG PG_VERSION=16

############################
# 1) Builder (heavy)
############################
FROM postgres:${PG_VERSION} AS builder

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
	  git \
      build-essential \
      postgresql-server-dev-${PG_MAJOR}; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/ext

RUN set -eux; \
    git clone --depth 1 --branch "fix-ttl-worker-main" "https://github.com/belkasoft/postgres-extensions-pg_ttl" .; \
    make clean; \
	make; \
    make install

############################
# 2) Runtime (small)
############################
FROM postgres:${PG_VERSION}
ARG EXT_NAME=pg_ttl_index

COPY --from=builder /usr/lib/postgresql/${PG_MAJOR}/lib/${EXT_NAME}.so \
                    /usr/lib/postgresql/${PG_MAJOR}/lib/

COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/${EXT_NAME}.control \
                    /usr/share/postgresql/${PG_MAJOR}/extension/
COPY --from=builder /usr/share/postgresql/${PG_MAJOR}/extension/${EXT_NAME}--*.sql \
                    /usr/share/postgresql/${PG_MAJOR}/extension/

# The postgres image already has the correct ENTRYPOINT and CMD
