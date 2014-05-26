#!/bin/bash

echo before drop cache:
vmstat
sync;
echo 3 > /proc/sys/vm/drop_caches
echo after drop cache:
vmstat


# sudo -u postgres psql -d cse135
# create extension adminpack;
# create extension pg_buffercache;
# \dx pg_buffercache

# SELECT c.relname, count(*) AS buffers
# FROM pg_buffercache b INNER JOIN pg_class c
# ON b.relfilenode = pg_relation_filenode(c.oid) AND
# b.reldatabase IN (0, (SELECT oid FROM pg_database
# WHERE datname = current_database()))
# GROUP BY c.relname
# ORDER BY 2 DESC
# LIMIT 10;

SELECT pg_size_pretty(pg_database_size('cse135'));
SELECT pg_size_pretty(pg_total_relation_size('cse135'));