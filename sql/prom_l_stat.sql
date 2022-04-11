-- -*- Mode: SQL; indent-tabs-mode: nil; coding: utf-8; show-trailing-whitespace: t -*-
--

use PROM_EXPORTER;

create procedure l_stat_format (
  in key_table varchar,
  in index_name varchar,
  in locks integer,
  in waits integer,
  in wait_pct integer,
  in deadlocks integer,
  in lock_esc integer,
  in wait_msecs integer)
{
  declare ts bigint;
  ts := make_timestamp();

  http (sprintf ('virt_l_stat_locks{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, locks, ts));
  http (sprintf ('virt_l_stat_waits{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, waits, ts));
  http (sprintf ('virt_l_stat_wait_pct{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, wait_pct, ts));
  http (sprintf ('virt_l_stat_deadlocks{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, deadlocks, ts));
  http (sprintf ('virt_l_stat_lock_esc{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, lock_esc, ts));
  http (sprintf ('virt_l_stat_wait_msecs{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, wait_msecs, ts));
}
;

----

create procedure
prom_l_stat_exporter () {
  http ('# TYPE virt_l_stat_locks counter\n');
  http ('# TYPE virt_l_stat_waits counter\n');
  http ('# TYPE virt_l_stat_wait_pct gauge\n');
  http ('# TYPE virt_l_stat_deadlocks counter\n');
  http ('# TYPE virt_l_stat_lock_esc counter\n');
  http ('# TYPE virt_l_stat_wait_msecs counter\n');


  for (select key_table,
              index_name,
              locks,
              waits,
              wait_pct,
              deadlocks,
              lock_esc,
              wait_msecs
         from db.dba.sys_l_stat) do {
    l_stat_format (key_table, index_name, locks, waits, wait_pct, deadlocks, lock_esc, wait_msecs);
  }
}
;

-- EOF
