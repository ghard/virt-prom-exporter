-- -*- Mode: SQL; indent-tabs-mode: nil; coding: utf-8; show-trailing-whitespace: t -*-
--
--  This file is part of the virt_prom_exporter project.
--
--  Copyright (C) 2021-2022 Yrjänä Rankka
--
--  This project is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; only version 2 of the License, dated June 1991.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

use PROM_EXPORTER;

create procedure k_stat_format (
  in key_table varchar,
  in index_name varchar,
  in landed integer,
  in consec integer,
  in right_edge integer,
  in read_wait integer,
  in write_wait integer,
  in landing_wait integer,
  in pl_wait integer)
{
  declare ts bigint;
  ts := make_timestamp();

  http (sprintf ('k_stat_landed{key_table="%s", index_name="%s"} %d %ld\n',
                 key_table, index_name, landed, ts));
  http (sprintf ('k_stat_consec{key_table="%s", index_name="%s"} %d %ld\n',
                 key_table, index_name, consec, ts));
  http (sprintf ('k_stat_right_edge{key_table="%s", index_name="%s"} %d %ld\n',
                 key_table, index_name, right_edge, ts));
  http (sprintf ('k_stat_read_wait{key_table="%s", index_name="%s"} %d %ld\n',
                 key_table, index_name, read_wait, ts));
  http (sprintf ('k_stat_write_wait{key_table="%s", index_name="%s"} %d %ld\n',
                 key_table, index_name, write_wait, ts));
  http (sprintf ('k_stat_landing_wait{key_table="%s", index_name="%s"} %d %ld\n',
                 key_table, index_name, landing_wait, ts));
  http (sprintf ('k_stat_pl_wait{key_table="%s", index_name="%s"} %d %ld\n',
                 key_table, index_name, pl_wait, ts));
}
;

create procedure
prom_k_stat_exporter () {
  http ('# TYPE k_stat_landed counter\n');
  http ('# TYPE k_stat_consec counter\n');
  http ('# TYPE l_stat_right_edge counter\n');
  http ('# TYPE k_stat_read_wait counter\n');
  http ('# TYPE k_stat_write_wait counter\n');
  http ('# TYPE k_stat_landing_wait counter\n');
  http ('# TYPE k_stat_pl_wait counter\n');

  for (select key_table,
              index_name,
              landed,
              consec,
              right_edge,
              read_wait,
              write_wait,
              landing_wait,
              pl_wait
         from db.dba.sys_k_stat) do {
    k_stat_format (key_table,
                   index_name,
                   landed,
                   consec,
                   right_edge,
                   read_wait,
                   write_wait,
                   landing_wait,
                   pl_wait);
  }
}
;

-- EOF
