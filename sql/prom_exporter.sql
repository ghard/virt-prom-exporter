-- -*- Mode: SQL; indent-tabs-mode: nil; coding: utf-8;show-trailing-whitespace: t -*-
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

create procedure DB.virt_prom_soap.prom_exporter () __SOAP_HTTP 'text/plain'
{
  status();
  PROM_EXPORTER.DBA.prom_sys_stat_exporter();
  PROM_EXPORTER.DBA.prom_l_stat_exporter();
  PROM_EXPORTER.DBA.prom_k_stat_exporter();

  http_flush();
}
;

-- EOF
