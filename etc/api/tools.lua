--[[ Additional tools
  -- (c) Er2 2021 <er2@dismail.de>
  -- Zlib license
--]]

local tools = {
  json = require 'etc.json',
}

local json = tools.json
local https = require 'ssl.https'
local ltn12 = require 'ltn12'

function tools.fetchCmd(text)
  return
    text:match '/([%w_]+)',       -- cmd
    text:match '/[%w_]+@([%w_]+)' -- to
end

-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
function tools.urlencode(url)
  if url == nil then return end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w_%- . ~])", function(c) return string.format("%%%02X", string.byte(c)) end)
  url = url:gsub(" ", "+")
  return url
end

function tools.req(url, par)
  if type(par) == 'table' then
    url = url .. '?'
    for k,v in pairs(par) do
      url = url ..'&'.. k ..'='.. tools.urlencode(tostring(v))
    end
  end
  
  local resp = {}
  local succ, res = https.request {
    url = url,
    method = 'GET',
    sink = ltn12.sink.table(resp),
  }

  if not succ then
    print('Connection error [' .. res .. ']')
    return nil, false
  end
  return resp[1], true
end

function tools.requ(url, par, dbg)
  local res, succ = tools.req(url, par)
  if dbg then print(url, succ, res) end
  res = json.decode(res or '{}')
  if not succ or not res then return {}, false end
  return res, true
end

function tools.request(token, endpoint, param, dbg)
  assert(token, 'Provide token!')
  assert(endpoint, 'Provide endpoint!')

  local url = 'https://api.telegram.org/bot' .. token .. '/' .. endpoint

  -- dbg = true
  local resp = tools.requ(url, param, dbg)
  return resp, resp.ok or false
end

return tools
