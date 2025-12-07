# PostgreSQL with pg_ttl_index Extension - Docker Image

This repository automatically builds Docker images containing PostgreSQL with the `pg_ttl_index` extension pre-installed.

## About pg_ttl_index

The `pg_ttl_index` extension provides automatic Time-To-Live (TTL) functionality for PostgreSQL tables. It allows you to specify an expiration time for rows based on a timestamp or date column, with automatic cleanup of expired records.

## Available Images

Images are available on GitHub Container Registry:

```bash
docker pull ghcr.io/belkasoft/postgres:latest
```

### Tags

- `latest` - Latest build with PostgreSQL 16
- `pg14`, `pg15`, `pg16` - Specific PostgreSQL version
- `pg{version}-{sha}` - Version with specific commit SHA
- Version tags (e.g., `v1.0.0`) - Release versions

## Usage

### Basic Usage

```bash
docker run -d \
  --name postgres-ttl \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  ghcr.io/belkasoft/postgres:latest
```

### Using the pg_ttl_index Extension

1. Connect to your database:

```bash
docker exec -it postgres-ttl psql -U postgres
```

2. Create the extension:

```sql
CREATE EXTENSION pg_ttl_index;
```

3. Create a table and set up TTL:

```sql
-- Create a sample table
CREATE TABLE user_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data JSONB
);

-- Create TTL index to expire sessions after 1 hour (3600 seconds)
SELECT ttl_create_index('user_sessions', 'created_at', 3600);
```

4. The extension will automatically delete expired rows every 60 seconds (configurable).

### Configuration

The `pg_ttl_index` extension is pre-loaded via `shared_preload_libraries`. You can configure it using environment variables or by mounting a custom `postgresql.conf`:

```bash
docker run -d \
  --name postgres-ttl \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -v /path/to/custom/postgresql.conf:/etc/postgresql/postgresql.conf \
  -p 5432:5432 \
  ghcr.io/belkasoft/postgres:latest \
  -c config_file=/etc/postgresql/postgresql.conf
```

## Extension Functions

- `ttl_create_index(table_name, timestamp_column, ttl_seconds)` - Create a TTL index
- `ttl_drop_index(table_name, timestamp_column)` - Drop a TTL index
- `ttl_runner()` - Manually trigger cleanup (optional)

## Building Locally

To build the image locally:

```bash
# Build with PostgreSQL 16 (default)
docker build -t postgres-ttl:latest .

# Build with specific PostgreSQL version
docker build --build-arg PG_VERSION=15 -t postgres-ttl:pg15 .
```

## References

- [pg_ttl_index Extension](https://github.com/ibrahimkarimeddin/postgres-extensions-pg_ttl)
- [PostgreSQL Official Docker Image](https://hub.docker.com/_/postgres)

## License

This Dockerfile and workflow configuration are provided as-is. PostgreSQL and pg_ttl_index have their own respective licenses.
