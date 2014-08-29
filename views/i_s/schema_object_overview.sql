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
 * View: schema_object_overview
 * 
 * Shows an overview of the types of objects within each schema
 *
 * Note: On instances with a large number of objects, this could take
 *       some time to execute, and is not recommended.
 *
 * mysql> select * from schema_object_overview;
 * +---------------------------------+---------------+-------+
 * | db                              | object_type   | count |
 * +---------------------------------+---------------+-------+
 * | information_schema              | SYSTEM VIEW   |    59 |
 * | mem30_test__instruments         | BASE TABLE    |     1 |
 * | mem30_test__instruments         | INDEX (BTREE) |     2 |
 * | mem30_test__test                | BASE TABLE    |     9 |
 * | mem30_test__test                | INDEX (BTREE) |    19 |
 * ...
 * | sys                             | FUNCTION      |     8 |
 * | sys                             | PROCEDURE     |    16 |
 * | sys                             | VIEW          |    59 |
 * +---------------------------------+---------------+-------+
 *
 */

CREATE OR REPLACE
  ALGORITHM = TEMPTABLE
  DEFINER = CURRENT_USER
  SQL SECURITY INVOKER 
VIEW schema_object_overview (
  db,
  object_type,
  count
) AS
SELECT ROUTINE_SCHEMA AS db, ROUTINE_TYPE AS object_type, COUNT(*) AS count FROM INFORMATION_SCHEMA.ROUTINES GROUP BY ROUTINE_SCHEMA, ROUTINE_TYPE
 UNION 
SELECT TABLE_SCHEMA, TABLE_TYPE, COUNT(*) FROM INFORMATION_SCHEMA.TABLES GROUP BY TABLE_SCHEMA, TABLE_TYPE
 UNION
SELECT TABLE_SCHEMA, CONCAT('INDEX (', INDEX_TYPE, ')'), COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS GROUP BY TABLE_SCHEMA, INDEX_TYPE
 UNION
SELECT TRIGGER_SCHEMA, 'TRIGGER', COUNT(*) FROM INFORMATION_SCHEMA.TRIGGERS GROUP BY TRIGGER_SCHEMA
 UNION
SELECT EVENT_SCHEMA, 'EVENT', COUNT(*) FROM INFORMATION_SCHEMA.EVENTS GROUP BY EVENT_SCHEMA
ORDER BY DB, OBJECT_TYPE;
