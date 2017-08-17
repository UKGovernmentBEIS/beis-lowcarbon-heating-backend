#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER beis;
    CREATE DATABASE beis;
    GRANT ALL PRIVILEGES ON DATABASE beis TO beis;
EOSQL
