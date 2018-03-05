--[[ Copyright (C) 2013-2018 PUC-Rio/Laboratorio TeleMidia

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
along with NCLua.  If not, see <https://www.gnu.org/licenses/>.  ]]--

local tests = require ('tests')
local ASSERT = tests.ASSERT
local ASSERT_ERROR = tests.ASSERT_ERROR

local settings = require ('nclua.settings')

ASSERT (settings.luaVersion == tests.NCLUA_VERSION)
ASSERT (settings.luaVersionMajor == tests.NCLUA_VERSION_MAJOR)
ASSERT (settings.luaVersionMinor == tests.NCLUA_VERSION_MINOR)
ASSERT (settings.luaVersionMicro == tests.NCLUA_VERSION_MICRO)