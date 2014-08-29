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
 * View: waits_global_by_latency
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large).
 *
 * mysql> select * from waits_global_by_latency limit 5;
 * +--------------------------------------+------------+---------------+-------------+-------------+
 * | event                                | total      | total_latency | avg_latency | max_latency |
 * +--------------------------------------+------------+---------------+-------------+-------------+
 * | wait/io/file/myisam/dfile            | 3623719744 | 00:47:49.09   | 791.70 ns   | 312.96 ms   |
 * | wait/io/table/sql/handler            |   69114944 | 00:44:30.74   | 38.64 us    | 879.49 ms   |
 * | wait/io/file/innodb/innodb_log_file  |   28100261 | 00:37:42.12   | 80.50 us    | 476.00 ms   |
 * | wait/io/socket/sql/client_connection |  200704863 | 00:18:37.81   | 5.57 us     | 1.27 s      |
 * | wait/io/file/innodb/innodb_data_file |    2829403 | 00:08:12.89   | 174.20 us   | 455.22 ms   |
 * +--------------------------------------+------------+---------------+-------------+-------------+
 * 
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW waits_global_by_latency (
  events,
  total,
  total_latency,
  avg_latency,
  max_latency
) AS
SELECT event_name AS event,
       count_star AS total,
       sys.format_time(sum_timer_wait) AS total_latency,
       sys.format_time(avg_timer_wait) AS avg_latency,
       sys.format_time(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE event_name != 'idle'
   AND sum_timer_wait > 0
 ORDER BY sum_timer_wait DESC;

/*
 * View: x$waits_global_by_latency
 *
 * Lists the top wait events by their total latency, ignoring idle (this may be very large).
 *
 * mysql> select * from x$waits_global_by_latency limit 5;
 * +--------------------------------------+-------+---------------+-------------+--------------+
 * | event                                | total | total_latency | avg_latency | max_latency  |
 * +--------------------------------------+-------+---------------+-------------+--------------+
 * | wait/io/file/sql/file_parser         |   679 | 3536136351540 |  5207858773 | 129860439800 |
 * | wait/io/file/innodb/innodb_data_file |   195 |  848170566100 |  4349592637 | 350700491310 |
 * | wait/io/file/sql/FRM                 |  1355 |  400428476500 |   295518990 |  44823120940 |
 * | wait/io/file/innodb/innodb_log_file  |    20 |   54298899070 |  2714944765 |  30108124800 |
 * | wait/io/file/mysys/charset           |     3 |   24244722970 |  8081574072 |  24151547420 |
 * +--------------------------------------+-------+---------------+-------------+--------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$waits_global_by_latency (
  events,
  total,
  total_latency,
  avg_latency,
  max_latency
) AS
SELECT event_name AS event,
       count_star AS total,
       sum_timer_wait AS total_latency,
       avg_timer_wait AS avg_latency,
       max_timer_wait AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE event_name != 'idle'
   AND sum_timer_wait > 0
 ORDER BY sum_timer_wait DESC;
