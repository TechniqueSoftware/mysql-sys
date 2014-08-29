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
 * View: wait_classes_global_by_avg_latency
 * 
 * Lists the top wait classes by average latency, ignoring idle (this may be very large).
 *
 * mysql> select * from wait_classes_global_by_avg_latency where event_class != 'idle';
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 * | event_class       | total  | total_latency | min_latency | avg_latency | max_latency |
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 * | wait/io/file      | 543123 | 44.60 s       | 19.44 ns    | 82.11 µs    | 4.21 s      |
 * | wait/io/table     |  22002 | 766.60 ms     | 148.72 ns   | 34.84 µs    | 44.97 ms    |
 * | wait/io/socket    |  79613 | 967.17 ms     | 0 ps        | 12.15 µs    | 27.10 ms    |
 * | wait/lock/table   |  35409 | 18.68 ms      | 65.45 ns    | 527.51 ns   | 969.88 µs   |
 * | wait/synch/rwlock |  37935 | 4.61 ms       | 21.38 ns    | 121.61 ns   | 34.65 µs    |
 * | wait/synch/mutex  | 390622 | 18.60 ms      | 19.44 ns    | 47.61 ns    | 10.32 µs    |
 * +-------------------+--------+---------------+-------------+-------------+-------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW wait_classes_global_by_avg_latency (
  event_class,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency
) AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) AS event_class,
       SUM(COUNT_STAR) AS total,
       sys.format_time(CAST(SUM(sum_timer_wait) AS UNSIGNED)) AS total_latency,
       sys.format_time(MIN(min_timer_wait)) AS min_latency,
       sys.format_time(IFNULL(SUM(sum_timer_wait) / NULLIF(SUM(COUNT_STAR), 0), 0)) AS avg_latency,
       sys.format_time(CAST(MAX(max_timer_wait) AS UNSIGNED)) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY event_class
 ORDER BY IFNULL(SUM(sum_timer_wait) / NULLIF(SUM(COUNT_STAR), 0), 0) DESC;

/*
 * View: x$wait_classes_global_by_avg_latency
 * 
 * Lists the top wait classes by average latency, ignoring idle (this may be very large).
 *
 * mysql> select * from x$wait_classes_global_by_avg_latency;
 * +-------------------+---------+-------------------+-------------+--------------------+------------------+
 * | event_class       | total   | total_latency     | min_latency | avg_latency        | max_latency      |
 * +-------------------+---------+-------------------+-------------+--------------------+------------------+
 * | idle              |    4331 | 16044682716000000 |     2000000 | 3704613880397.1369 | 1593550454000000 |
 * | wait/io/file      |   23037 |    20856702551880 |           0 |     905356711.0249 |     350700491310 |
 * | wait/io/table     |  224924 |      719670285750 |      116870 |       3199615.3623 |     208579012460 |
 * | wait/lock/table   |    6972 |        3674766030 |      109330 |        527074.8752 |          8855730 |
 * | wait/synch/rwlock |   11916 |        1273279800 |       37700 |        106854.6324 |          6838780 |
 * | wait/synch/mutex  | 1031881 |       80464286240 |       56550 |         77978.2613 |       2590408470 |
 * +-------------------+---------+-------------------+-------------+--------------------+------------------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$wait_classes_global_by_avg_latency (
  event_class,
  total,
  total_latency,
  min_latency,
  avg_latency,
  max_latency
) AS
SELECT SUBSTRING_INDEX(event_name,'/', 3) AS event_class,
       SUM(COUNT_STAR) AS total,
       SUM(sum_timer_wait) AS total_latency,
       MIN(min_timer_wait) AS min_latency,
       IFNULL(SUM(sum_timer_wait) / NULLIF(SUM(COUNT_STAR), 0), 0) AS avg_latency,
       MAX(max_timer_wait) AS max_latency
  FROM performance_schema.events_waits_summary_global_by_event_name
 WHERE sum_timer_wait > 0
   AND event_name != 'idle'
 GROUP BY event_class
 ORDER BY IFNULL(SUM(sum_timer_wait) / NULLIF(SUM(COUNT_STAR), 0), 0) DESC;
 