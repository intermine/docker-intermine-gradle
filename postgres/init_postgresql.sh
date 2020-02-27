#!/bin/bash
set -e

cd /opt

# initdb requires the user to be present in `/etc/passwd`, but we only know
# the user's ID and group ID during runtime (which is when we don't have root
# access). The solution is to use nss_wrapper to stub `/etc/passwd` and
# `/etc/group`. This is also the reason why we use the Debian container of
# postgres, instead of Alpine; the latter doesn't include nss_wrapper.
cp /etc/passwd .
cp /etc/group .
echo appuser:x:$(id -u):$(id -g):appuser:/home/appuser:/bin/false >> passwd
echo appuser:x:$(id -g): >> group
export LD_PRELOAD=/usr/lib/libnss_wrapper.so
export NSS_WRAPPER_PASSWD=./passwd
export NSS_WRAPPER_GROUP=./group

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
