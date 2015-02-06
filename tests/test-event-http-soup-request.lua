--[[ Copyright (C) 2013-2015 PUC-Rio/Laboratorio TeleMidia

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
local ASSERT_ERROR = tests.ASSERT_ERROR
local ASSERT_CHECK_OBJECT = tests.ASSERT_CHECK_OBJECT
local TRACE = tests.trace

local soup = require ('nclua.event.http_soup')
_ENV = nil

local function CYCLE_UNTIL (func)
   TRACE ('cycling')
   tests.soup.cycle_until (func)
end

-- A valid URI.
local URI = 'https://github.com/gflima/nclua/raw/master/README.md'

-- Sanity checks.
local session = soup.new ()
ASSERT_ERROR (soup.request)
ASSERT_ERROR (soup.request, session)
ASSERT_ERROR (soup.request, session, 1)
ASSERT_ERROR (soup.request, session, 'GET')
ASSERT_ERROR (soup.request, session, 'GET', URI, 1)
ASSERT_ERROR (soup.request, session, 'GET', URI, {}, nil)
ASSERT_ERROR (soup.request, session, 'GET', URI, {}, '', nil)

-- Sanity check: request an invalid URI.
ASSERT_ERROR (soup.request, session, 'GET', '<invalid-uri>', {}, '',
              function () end)

-- Sanity check: make a request with an invalid header name.
ASSERT_ERROR (soup.request, session, 'GET', URI, {['in\nvalid']='abc'}, '',
              function () end)

-- Sanity check: make a request with an invalid header value.
ASSERT_ERROR (soup.request, session, 'GET', URI, {['X-test']='\n'}, '',
              function () end)

-- Force an HTTP error.
local DONE = false
local function request_cb (status, soup, method, uri, code, headers, body)
   TRACE (status, method, uri, soup, code)
   -- tests.dump (headers)
   -- TRACE (body)
   ASSERT (status == true)
   ASSERT (code ~= 200)
   DONE = true
end

session:request ('POST', 'http://laws.deinf.ufma.br/404', {}, '',
                 request_cb)
CYCLE_UNTIL (function () return DONE end)

-- Make a successful request and checks the response body.
local response_body = ''
local DONE = false
local function request_cb (status, soup, method, uri, code, headers, body)
   TRACE (status, soup, method, uri, code)
   tests.dump (headers)
   ASSERT (status == true)
   ASSERT (code == 200)
   response_body = body
   DONE = true
end

session:request ('GET', URI, {}, '', request_cb)
CYCLE_UNTIL (function () return DONE end)

local readme = tests.read_file (tests.mk.top_srcdir..'/README.md')
ASSERT (response_body == readme)
