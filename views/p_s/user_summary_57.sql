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
 * View: user_summary
 *
 * Summarizes statement activity and connections by user
 *
 * mysql> select * from user_summary;
 * +------+------------+---------------+-------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | user | statements | total_latency | avg_latency | current_connections | total_connections | unique_hosts | current_memory | total_memory_allocated |
 * +------+------------+---------------+-------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | root |       5663 | 00:01:47.14   | 18.92 ms    |                   1 |                 1 |            1 | 1.41 MiB       | 543.55 MiB             |
 * | mark |        225 | 14.49 s       | 64.40 ms    |                   1 |                 1 |            1 | 707.60 KiB     | 81.02 MiB              |
 * +------+------------+---------------+-------------+---------------------+-------------------+--------------+----------------+------------------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary (
  user,
  statements,
  statement_latency,
  statement_avg_latency,
  table_scans,
  file_ios,
  file_io_latency,
  current_connections,
  total_connections,
  unique_hosts,
  current_memory,
  total_memory_allocated
) AS
SELECT accounts.user,
       SUM(stmt.total) AS statements,
       sys.format_time(SUM(stmt.total_latency)) AS statement_latency,
       sys.format_time(IFNULL(SUM(stmt.total_latency) / NULLIF(SUM(stmt.total), 0), 0)) AS statement_avg_latency,
       SUM(stmt.full_scans) AS table_scans,
       SUM(io.ios) AS file_ios,
       sys.format_time(SUM(io.io_latency)) AS file_io_latency,
       SUM(accounts.current_connections) AS current_connections,
       SUM(accounts.total_connections) AS total_connections,
       COUNT(DISTINCT host) AS unique_hosts,
       sys.format_bytes(mem.current_allocated) AS current_memory,
       sys.format_bytes(mem.total_allocated) AS total_memory_allocated
  FROM performance_schema.accounts
  JOIN sys.x$user_summary_by_statement_latency AS stmt ON accounts.user = stmt.user
  JOIN sys.x$user_summary_by_file_io AS io ON accounts.user = io.user
  JOIN sys.x$memory_by_user_by_current_bytes mem ON accounts.user = mem.user
 WHERE accounts.user IS NOT NULL
 GROUP BY accounts.user;

/*
 * View: x$user_summary
 *
 * Summarizes statement activity and connections by user
 *
 * mysql> select * from x$user_summary;
 * +------+------------+-----------------+------------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | user | statements | total_latency   | avg_latency      | current_connections | total_connections | unique_hosts | current_memory | total_memory_allocated |
 * +------+------------+-----------------+------------------+---------------------+-------------------+--------------+----------------+------------------------+
 * | root |       5685 | 107175100271000 | 18852260381.8821 |                   1 |                 1 |            1 |        1459022 |              572855680 |
 * | mark |        225 |  14489223428000 | 64396548568.8889 |                   1 |                 1 |            1 |         724578 |               84958286 |
 * +------+------------+-----------------+------------------+---------------------+-------------------+--------------+----------------+------------------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary (
  user,
  statements,
  statement_latency,
  statement_avg_latency,
  table_scans,
  file_ios,
  file_io_latency,
  current_connections,
  total_connections,
  unique_hosts,
  current_memory,
  total_memory_allocated
) AS
SELECT accounts.user,
       SUM(stmt.total) AS statements,
       SUM(stmt.total_latency) AS statement_latency,
       IFNULL(SUM(stmt.total_latency) / NULLIF(SUM(stmt.total), 0), 0) AS statement_avg_latency,
       SUM(stmt.full_scans) AS table_scans,
       SUM(io.ios) AS file_ios,
       SUM(io.io_latency) AS file_io_latency,
       SUM(accounts.current_connections) AS current_connections,
       SUM(accounts.total_connections) AS total_connections,
       COUNT(DISTINCT host) AS unique_hosts,
       mem.current_allocated AS current_memory,
       mem.total_allocated AS total_memory_allocated
  FROM performance_schema.accounts
  JOIN sys.x$user_summary_by_statement_latency AS stmt ON accounts.user = stmt.user
  JOIN sys.x$user_summary_by_file_io AS io ON accounts.user = io.user
  JOIN sys.x$memory_by_user_by_current_bytes mem ON accounts.user = mem.user
 WHERE accounts.user IS NOT NULL
 GROUP BY accounts.user;
