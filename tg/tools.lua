local tools = {
  json = require 'tg.json',
}

local json = tools.json
local https = require 'ssl.https'
local ltn12 = require 'ltn12'

function tools.fetchCmd(text)
  local cmd = text:match '/[%w_]+'
  local to = text:match '/[%w_]+(@[%w_]+)'
  if to then to = to:sub(2) end
  if cmd then cmd = cmd:sub(2) end
  return cmd, to
end

-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
function tools.urlencode(url)
  if url == nil then return end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w_%- . ~])", function(c) return string.format("%%%02X", string.byte(c)) end)
  url = url:gsub(" ", "+")
  return url
end

function tools.req(url)
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

function tools.requ(url)
  local res, succ = tools.req(url)
  res = json.decode(res or '{}')
  if not succ or not res then return {}, false end
  return res, true
end

function tools.request(token, endpoint, param)
  assert(token, 'Provide token!')
  assert(endpoint, 'Provide endpoint!')

  local params = ''
  for k, v in pairs(param or {}) do
    params = params .. '&' .. k .. '=' .. tools.urlencode(tostring(v))
  end

  local url = 'https://api.telegram.org/bot' .. token .. '/' .. endpoint
  if #params > 1 then url = url .. '?' .. params:sub(2) end

  local resp = tools.requ(url)
  return resp, resp.ok or false
end

return tools