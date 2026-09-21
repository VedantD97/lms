#!/bin/bash
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE DATABASE lms_production;
  CREATE DATABASE lms_production_cache;
  CREATE DATABASE lms_production_queue;
EOSQL
