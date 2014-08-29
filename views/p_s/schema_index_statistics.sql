/* Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA */

/*
 * View: schema_index_statistics
 *
 * Statistics around indexes.
 *
 * Ordered by the total wait time descending - top indexes are most contended.
 *
 * mysql> select * from schema_index_statistics limit 5;
 * +------------------+-------------+------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | table_schema     | table_name  | index_name | rows_selected | select_latency | rows_inserted | insert_latency | rows_updated | update_latency | rows_deleted | delete_latency |
 * +------------------+-------------+------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | mem              | mysqlserver | PRIMARY    |          6208 | 108.27 ms      |             0 | 0 ps           |         5470 | 1.47 s         |            0 | 0 ps           |
 * | mem              | innodb      | PRIMARY    |          4666 | 76.27 ms       |             0 | 0 ps           |         4454 | 571.47 ms      |            0 | 0 ps           |
 * | mem              | connection  | PRIMARY    |          1064 | 20.98 ms       |             0 | 0 ps           |         1064 | 457.30 ms      |            0 | 0 ps           |
 * | mem              | environment | PRIMARY    |          5566 | 151.17 ms      |             0 | 0 ps           |          694 | 252.57 ms      |            0 | 0 ps           |
 * | mem              | querycache  | PRIMARY    |          1698 | 27.99 ms       |             0 | 0 ps           |         1698 | 371.72 ms      |            0 | 0 ps           |
 * +------------------+-------------+------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_index_statistics (
  table_schema,
  table_name,
  index_name,
  rows_selected,
  select_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency
) AS
SELECT OBJECT_SCHEMA AS table_schema,
       OBJECT_NAME AS table_name,
       INDEX_NAME as index_name,
       COUNT_FETCH AS rows_selected,
       sys.format_time(SUM_TIMER_FETCH) AS select_latency,
       COUNT_INSERT AS rows_inserted,
       sys.format_time(SUM_TIMER_INSERT) AS insert_latency,
       COUNT_UPDATE AS rows_updated,
       sys.format_time(SUM_TIMER_UPDATE) AS update_latency,
       COUNT_DELETE AS rows_deleted,
       sys.format_time(SUM_TIMER_INSERT) AS delete_latency
  FROM performance_schema.table_io_waits_summary_by_index_usage
 WHERE index_name IS NOT NULL
 ORDER BY sum_timer_wait DESC;

/*
 * View: x$schema_index_statistics
 *
 * Statistics around indexes.
 *
 * Ordered by the total wait time descending - top indexes are most contended.
 *
 * mysql> SELECT * FROM x$schema_index_statistics LIMIT 5;
 * +---------------+----------------------+-------------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | table_schema  | table_name           | index_name        | rows_selected | select_latency | rows_inserted | insert_latency | rows_updated | update_latency | rows_deleted | delete_latency |
 * +---------------+----------------------+-------------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 * | common_schema | _global_sql_tokens   | PRIMARY           |          1886 |     1129676730 |             0 |              0 |            0 |              0 |         1878 |              0 |
 * | common_schema | _script_statements   | PRIMARY           |          4606 |     4212160680 |             0 |              0 |            0 |              0 |            0 |              0 |
 * | common_schema | _global_qs_variables | declaration_depth |           256 |     1650193090 |             0 |              0 |           32 |     1372148050 |            0 |              0 |
 * | common_schema | _global_qs_variables | PRIMARY           |             0 |              0 |             0 |              0 |            0 |              0 |           16 |              0 |
 * | common_schema | metadata             | PRIMARY           |             5 |       76730810 |             0 |              0 |            4 |      114310170 |            0 |              0 |
 * +---------------+----------------------+-------------------+---------------+----------------+---------------+----------------+--------------+----------------+--------------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$schema_index_statistics (
  table_schema,
  table_name,
  index_name,
  rows_selected,
  select_latency,
  rows_inserted,
  insert_latency,
  rows_updated,
  update_latency,
  rows_deleted,
  delete_latency
) AS
SELECT OBJECT_SCHEMA AS table_schema,
       OBJECT_NAME AS table_name,
       INDEX_NAME as index_name,
       COUNT_FETCH AS rows_selected,
       SUM_TIMER_FETCH AS select_latency,
       COUNT_INSERT AS rows_inserted,
       SUM_TIMER_INSERT AS insert_latency,
       COUNT_UPDATE AS rows_updated,
       SUM_TIMER_UPDATE AS update_latency,
       COUNT_DELETE AS rows_deleted,
       SUM_TIMER_INSERT AS delete_latency
  FROM performance_schema.table_io_waits_summary_by_index_usage
 WHERE index_name IS NOT NULL
 ORDER BY sum_timer_wait DESC;
