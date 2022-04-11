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

create procedure
prom_sys_stat_exporter ()
{
  declare ts bigint;
  ts := make_timestamp();

  http ('# TYPE sys_stat_db_pages gauge\n');
  http (sprintf ('sys_stat_db_pages %s %ld\n',
                 sys_stat ('st_db_pages'), ts));

  http ('# TYPE sys_stat_db_free_pages gauge\n');
  http (sprintf ('sys_stat_db_free_pages %s %ld\n',
                 sys_stat ('st_db_free_pages'), ts));

  http ('# TYPE sys_stat_proc_served gauge\n');
  http (sprintf ('sys_stat_proc_served %s %ld\n',
                 sys_stat ('st_proc_served'), ts));

  http ('# TYPE sys_stat_proc_active gauge\n');
  http (sprintf ('sys_stat_proc_active %s %ld\n',
                 sys_stat ('st_proc_active'), ts));

  http ('# TYPE sys_stat_proc_running gauge\n');
  http (sprintf ('sys_stat_proc_running %s %ld\n',
                 sys_stat ('st_proc_running'), ts));

  http ('# TYPE sys_stat_proc_queued_req gauge\n');
  http (sprintf ('sys_stat_proc_queued_req %s %ld\n',
                 sys_stat ('st_proc_queued_req'), ts));

  http ('# TYPE sys_stat_proc_brk gauge\n');
  http (sprintf ('sys_stat_proc_brk{} %s %ld\n',
                 sys_stat ('st_proc_brk'), ts));

  http ('# TYPE sys_stat_db_buffers_total gauge\n');
  http (sprintf ('sys_stat_db_buffers_total %s %ld\n',
                 sys_stat ('st_db_buffers'), ts));

  http ('# TYPE sys_stat_db_buffers_used gauge\n');
  http (sprintf ('sys_stat_db_buffers_used{} %s %ld\n',
                 sys_stat ('st_db_used_buffers'), ts));

  http ('# TYPE sys_stat_db_buffers_dirty gauge\n');
  http (sprintf ('sys_stat_db_buffers_dirty %s %ld\n',
                 sys_stat ('st_db_dirty_buffers'), ts));

  http ('# TYPE sys_stat_db_buffers_wired gauge\n');
  http (sprintf ('sys_stat_db_buffers_wired %s %ld\n',
                 sys_stat ('st_db_wired_buffers'), ts));

  http ('# TYPE sys_stat_db_disk_read_avg gauge\n');
  http (sprintf ('sys_stat_db_disk_read_avg %s %ld\n',
                 sys_stat ('st_db_disk_read_avg'), ts));

  http ('# TYPE sys_stat_db_disk_read_pct gauge\n');
  http (sprintf ('sys_stat_db_disk_read_pct %s %ld\n',
                 sys_stat ('st_db_disk_read_pct'), ts));

  http ('# TYPE sys_stat_db_disk_read_last gauge\n');
  http (sprintf ('sys_stat_db_disk_read_last %s %ld\n',
                 sys_stat ('st_db_disk_read_last'), ts));

  http ('# TYPE sys_stat_db_disk_read_aheads counter\n');
  http (sprintf ('sys_stat_db_disk_read_aheads %s %ld\n',
                 sys_stat ('st_db_disk_read_aheads'), ts));

  http ('# TYPE sys_stat_db_disk_read_ahead_batch counter\n');
  http (sprintf ('sys_stat_db_disk_read_ahead_batch %s %ld\n',
                 sys_stat ('st_db_disk_read_ahead_batch'), ts));

  http ('# TYPE sys_stat_db_disk_second_reads counter\n');
  http (sprintf ('sys_stat_db_disk_second_reads %s %ld\n',
                 sys_stat ('st_db_disk_second_reads'), ts));

  http ('# TYPE sys_stat_db_disk_in_while_read counter\n');
  http (sprintf ('sys_stat_db_disk_in_while_read %s %ld\n',
                 sys_stat ('st_db_disk_in_while_read'), ts));

--  http ('# TYPE sys_stat_log_length gauge\n');
--  http (sprintf ('sys_stat_log_length %s %ld\n',
--                       sys_stat ('st_log_length'), ts));

  http ('# TYPE sys_stat_cli_connects counter\n');
  http (sprintf ('sys_stat_cli_connects %s %ld\n',
                 sys_stat ('st_cli_connects'), ts));

  http ('# TYPE sys_stat_cli_max_connected gauge\n');
  http (sprintf ('sys_stat_cli_max_connected %s %ld\n',
                 sys_stat ('st_cli_max_connected'), ts));

  http ('# TYPE sys_stat_cli_n_current_connections gauge\n');
  http (sprintf ('sys_stat_cli_n_current_connections %s %ld\n',
                 sys_stat ('st_cli_n_current_connections'), ts));

  http ('# TYPE sys_stat_cli_n_http_threads gauge\n');
  http (sprintf ('sys_stat_cli_n_http_threads %s %ld\n',
                 sys_stat ('st_cli_n_http_threads'), ts));

  http ('# TYPE sys_stat_inx_pages_changed gauge\n');
  http (sprintf ('sys_stat_inx_pages_changed %s %ld\n',
                 sys_stat ('st_inx_pages_changed'), ts));

  http ('# TYPE sys_stat_inx_pages_new gauge\n');
  http (sprintf ('sys_stat_inx_pages_new %s %ld\n',
                 sys_stat ('st_inx_pages_new'), ts));

  http ('# TYPE sys_stat_chkp_remap_pages gauge\n');
  http (sprintf ('sys_stat_chkp_remap_pages %s %ld\n',
                 sys_stat ('st_chkp_remap_pages'), ts));

  http ('# TYPE sys_stat_chkp_mapback_pages gauge\n');
  http (sprintf ('sys_stat_chkp_mapback_pages %s %ld\n',
                 sys_stat ('st_chkp_mapback_pages'), ts));

  http ('# TYPE sys_stat_chkp_atomic_time gauge\n');
  http (sprintf ('sys_stat_chkp_atomic_time %s %ld\n',
                 sys_stat ('st_chkp_atomic_time'), ts));

  http ('# TYPE sys_stat_chkp_last_checkpointed gauge\n');
  http (sprintf ('sys_stat_chkp_last_checkpointed %s %ld\n',
                 sys_stat ('st_chkp_last_checkpointed'), ts));

  http ('# TYPE sys_stat_chkp_last_autocheckpoint gauge\n');
  http (sprintf ('sys_stat_chkp_autocheckpoint %s %ld\n',
                 sys_stat ('st_chkp_autocheckpoint'), ts));

}
;

-- EOF
