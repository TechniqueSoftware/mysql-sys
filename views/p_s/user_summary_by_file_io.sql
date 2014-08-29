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
 * View: user_summary_by_file_io
 *
 * Summarizes file IO totals per user.
 *
 * When the user found is NULL, it is assumed to be a "background" thread.
 *
 * mysql> select * from user_summary_by_file_io;
 * +------------+-------+------------+
 * | user       | ios   | io_latency |
 * +------------+-------+------------+
 * | root       | 26457 | 21.58 s    |
 * | background |  1189 | 394.21 ms  |
 * +------------+-------+------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW user_summary_by_file_io (
  user,
  ios,
  io_latency
) AS
SELECT user, 
       SUM(total) AS ios,
       sys.format_time(SUM(latency)) AS io_latency 
  FROM x$user_summary_by_file_io_type
 GROUP BY user
 ORDER BY SUM(latency) DESC;

/*
 * View: x$user_summary_by_file_io
 *
 * Summarizes file IO totals per user.
 *
 * When the user found is NULL, it is assumed to be a "background" thread.
 *
 * mysql> select * from x$user_summary_by_file_io;
 * +------------+-------+----------------+
 * | user       | ios   | io_latency     |
 * +------------+-------+----------------+
 * | root       | 26457 | 21579585586390 |
 * | background |  1189 |   394212617370 |
 * +------------+-------+----------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$user_summary_by_file_io (
  user,
  ios,
  io_latency
) AS
SELECT user, 
       SUM(total) AS ios,
       SUM(latency) AS io_latency 
  FROM x$user_summary_by_file_io_type
 GROUP BY user
 ORDER BY SUM(latency) DESC;
