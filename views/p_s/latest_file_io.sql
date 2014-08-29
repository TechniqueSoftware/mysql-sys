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
 * View: latest_file_io
 *
 * Shows the latest file IO, by file / thread.
 *
 * mysql> select * from latest_file_io limit 5;
 * +----------------------+----------------------------------------+------------+-----------+-----------+
 * | thread               | file                                   | latency    | operation | requested |
 * +----------------------+----------------------------------------+------------+-----------+-----------+
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 9.26 µs    | write     | 124 bytes |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 4.00 µs    | write     | 2 bytes   |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 56.34 µs   | close     | NULL      |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYD             | 53.93 µs   | close     | NULL      |
 * | msandbox@localhost:1 | @@tmpdir/#sqlcf28_1_4e.MYI             | 104.05 ms  | delete    | NULL      |
 * +----------------------+----------------------------------------+------------+-----------+-----------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW latest_file_io (
  thread,
  file,
  latency,
  operation,
  requested
) AS
SELECT IF(id IS NULL, 
             CONCAT(SUBSTRING_INDEX(name, '/', -1), ':', thread_id), 
             CONCAT(user, '@', host, ':', id)
          ) thread, 
       sys.format_path(object_name) file, 
       sys.format_time(timer_wait) AS latency, 
       operation, 
       sys.format_bytes(number_of_bytes) AS requested
  FROM performance_schema.events_waits_history_long 
  JOIN performance_schema.threads USING (thread_id)
  LEFT JOIN information_schema.processlist ON processlist_id = id
 WHERE object_name IS NOT NULL
   AND event_name LIKE 'wait/io/file/%'
 ORDER BY timer_start;

/*
 * View: x$latest_file_io
 *
 * Shows the latest file IO, by file / thread.
 *
 * mysql> SELECT * FROM x$latest_file_io LIMIT 5;
 * +------------------+------------------------------------------------------------------------------------+-------------+-----------+-----------+
 * | thread           | file                                                                               | latency     | operation | requested |
 * +------------------+------------------------------------------------------------------------------------+-------------+-----------+-----------+
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/user_summary_by_statement_type.frm~ |    26152490 | write     |      4210 |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/user_summary_by_statement_type.frm~ | 30062722690 | sync      |      NULL |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/user_summary_by_statement_type.frm~ |    34144890 | close     |      NULL |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/check_lost_instrumentation.frm      |   113001980 | open      |      NULL |
 * | root@localhost:6 | /Users/mark/sandboxes/msb_5_7_2/data/ps_helper/check_lost_instrumentation.frm      |     9553180 | read      |        10 |
 * +------------------+------------------------------------------------------------------------------------+-------------+-----------+-----------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = MERGE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW x$latest_file_io (
  thread,
  file,
  latency,
  operation,
  requested
) AS
SELECT IF(id IS NULL, 
             CONCAT(SUBSTRING_INDEX(name, '/', -1), ':', thread_id), 
             CONCAT(user, '@', host, ':', id)
          ) thread, 
       object_name file, 
       timer_wait AS latency, 
       operation, 
       number_of_bytes AS requested
  FROM performance_schema.events_waits_history_long 
  JOIN performance_schema.threads USING (thread_id)
  LEFT JOIN information_schema.processlist ON processlist_id = id
 WHERE object_name IS NOT NULL
   AND event_name LIKE 'wait/io/file/%'
 ORDER BY timer_start;
