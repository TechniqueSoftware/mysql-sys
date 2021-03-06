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

DROP PROCEDURE IF EXISTS ps_setup_enable_consumers;

DELIMITER $$

CREATE DEFINER=CURRENT_USER PROCEDURE ps_setup_enable_consumers (
        IN consumer VARCHAR(128)
    )
    COMMENT '
             Description
             -----------

             Enables consumers within Performance Schema 
             matching the input pattern.

             Parameters
             -----------

             consumer (VARCHAR(128)):
               A LIKE pattern match (using "%consumer%") of consumers to enable

             Example
             -----------

             To enable all consumers:

             mysql> CALL sys.ps_setup_enable_consumers(\'\');
             +-------------------------+
             | summary                 |
             +-------------------------+
             | Enabled 10 consumers    |
             +-------------------------+
             1 row in set (0.02 sec)

             Query OK, 0 rows affected (0.02 sec)

             To enable just "waits" consumers:

             mysql> CALL sys.ps_setup_enable_consumers(\'waits\');
             +-----------------------+
             | summary               |
             +-----------------------+
             | Enabled 3 consumers   |
             +-----------------------+
             1 row in set (0.00 sec)

             Query OK, 0 rows affected (0.00 sec)
             '
    SQL SECURITY INVOKER
    NOT DETERMINISTIC
    MODIFIES SQL DATA
BEGIN

    UPDATE performance_schema.setup_consumers
       SET enabled = 'YES'
     WHERE name LIKE CONCAT('%', consumer, '%');

    SELECT CONCAT('Enabled ', @rows := ROW_COUNT(), ' consumer', IF(@rows != 1, 's', '')) AS summary;

END$$

DELIMITER ;
