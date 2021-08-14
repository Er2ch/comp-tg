--[[ Additional tools
  -- (c) Er2 2021 <er2@dismail.de>
  -- Zlib license
--]]

local tools = {
  json = require 'etc.json',
}

local json  = tools.json
local https = require 'ssl.https'
local ltn12 = require 'ltn12'
local mp    = require 'etc.multipart'

function tools.fetchCmd(text)
  return
    text:match '/([%w_]+)',       -- cmd
    text:match '/[%w_]+@([%w_]+)' -- to
end

function tools._req(url, meth, data, ctype)
  assert(url,  'Provide URL!')
  assert(meth, 'Provide method!')

  local resp = {}
  local head = {
    url      = url,
    method   = meth,
    headers  = {
      ['Content-Type']   = ctype,
      ['Content-Length'] = #(data or ''),
    },
    source   = ltn12.source.string(data),
    sink     = ltn12.sink.table(resp),
  }

  local succ, res = https.request(head)
  if not succ then
    print('Connection error [' .. res .. ']')
    return nil, false
  end
  return resp[1], true
end

function tools.preq(url, par)
  par = par or {}

  local body, bound = mp.encode(par)
  return tools._req(
    url,
    'POST',
    body,
    'multipart/form-data; boundary=' .. bound
  )
end

function tools.greq(url, par, f)
  par = json.encode(par)
  return tools._req(url, 'GET', par, 'application/json')
end

function tools.req(url, par, f, dbg)
  local res, succ
  par = par or {}

  -- files
  if f and next(f) ~= nil then
    par = par or {}
    for k, v in pairs(par) do par[k] = tostring(v) end
    local ft, fn = next(f)
    local fr = io.open(fn, 'r')
    if fr then
      par[ft] = {
        filename = fn,
	data = fr:read '*a'
      }
      fr:close()
    else par[ft] = fn end
    res, succ = tools.preq(url, par)
  else -- text
    res, succ = tools.greq(url, par)
  end

  if dbg then print(url, succ, res, par)
    -- dump(par))
  end
  res = json.decode(res or '{}')
  if not succ or not res then return {}, false end
  return res, true
end

function tools.request(token, endpoint, param, f, dbg)
  assert(token, 'Provide token!')
  assert(endpoint, 'Provide endpoint!')

  local url = 'https://api.telegram.org/bot' ..token.. '/' ..endpoint

  -- dbg = true
  local resp = tools.req(url, param, f, dbg)
  return resp, resp.ok or false
end

return tools
