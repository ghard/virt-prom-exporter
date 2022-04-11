-- -*- Mode: SQL; indent-tabs-mode: nil; coding: utf-8; show-trailing-whitespace: t -*-
--
--  This file is part of the virt-prom project.
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

create procedure make_timestamp ()
{
  return cast (datediff ('millisecond', stringdate('1970-01-01 00:00:00Z'), curutcdatetime()) as bigint);
}
;

-- EOF
