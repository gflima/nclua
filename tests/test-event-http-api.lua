--[[ Copyright (C) 2013-2016 PUC-Rio/Laboratorio TeleMidia

This file is part of NCLua.

NCLua is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

NCLua is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for more details.

You should have received a copy of the GNU General Public License
along with NCLua.  If not, see <http://www.gnu.org/licenses/>.  ]]--

local tests = require ('tests')
local ASSERT = tests.ASSERT
local ASSERT_CHECK_API = tests.ASSERT_CHECK_API
local ASSERT_CHECK_OBJECT = tests.ASSERT_CHECK_OBJECT

local http = require ('nclua.event.http')
_ENV = nil

ASSERT_CHECK_API {
   http,
   INQ = 'table',
   OUTQ = 'table',
   check = 'function',
   class = 'string',
   cycle = 'function',
   filter = 'function',
   receive = 'function',
   reset = 'function',
   send = 'function',
}

ASSERT (http.class == 'http')
ASSERT_CHECK_OBJECT (http, 'table')
