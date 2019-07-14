#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 --username ${PGUSER:-postgres} <<-EOSQL
    update pg_database set datallowconn = TRUE where datname = 'template0';
    \c template0
    update pg_database set datistemplate = FALSE where datname = 'template1';
    drop database template1;
    create database template1 with template = template0 encoding = 'SQL_ASCII' LC_COLLATE='C' LC_CTYPE='C';
    update pg_database set datistemplate = TRUE where datname = 'template1';
    \c template1
    update pg_database set datallowconn = FALSE where datname = 'template0';
EOSQL
