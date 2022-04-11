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

  http (sprintf ('l_stat_locks{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, locks, ts));
  http (sprintf ('l_stat_waits{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, waits, ts));
  http (sprintf ('l_stat_wait_pct{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, wait_pct, ts));
  http (sprintf ('l_stat_deadlocks{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, deadlocks, ts));
  http (sprintf ('l_stat_lock_esc{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, lock_esc, ts));
  http (sprintf ('l_stat_wait_msecs{key_table="%s", index_name="%s"} %d %ld\n',
                      key_table, index_name, wait_msecs, ts));
}
;

----

create procedure
prom_l_stat_exporter () {
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
