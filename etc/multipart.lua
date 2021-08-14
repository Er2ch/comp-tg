-- based on https://github.com/catwell/lua-multipart-post
-- MIT License

local ltn12 = require 'ltn12'
local mp = {
  CHARSET  = 'UTF-8',
  LANGUAGE = ''
}

-- https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99
local function urlencode(url)
  if url == nil then return end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w_%- . ~])", function(c) return string.format("%%%02X", string.byte(c)) end)
  url = url:gsub(" ", "+")
  return url
end
mp.urlencode = urlencode

local function fmt(p, ...)
  if select('#', ...) == 0 then
    return p
  end
  return string.format(p, ...)
end

local function tprintf(t, p, ...)
  t[#t+1] = fmt(p, ...)
end

local function section_header(r, k, extra)
  tprintf(r, 'content-disposition: form-data; name="%s"', k)
  if extra.filename then
    tprintf(r, '; filename="%s"', extra.filename)
    tprintf(
      r, "; filename*=%s'%s'%s",
      mp.CHARSET, mp.LANGUAGE, urlencode(extra.filename)
    )
  end
  if extra.content_type then
    tprintf(r, '\r\ncontent-type: %s', extra.content_type)
  end
  if extra.content_transfer_encoding then
    tprintf(
      r, '\r\ncontent-transfer-encoding: %s',
      extra.content_transfer_encoding
    )
  end
  tprintf(r, '\r\n\r\n')
end

function mp.boundary()
  local t = {"BOUNDARY-"}
  for i=2,17 do t[i] = string.char(math.random(65, 90)) end
  t[18] = "-BOUNDARY"
  return table.concat(t)
end

local function encode_header_to_table(r, k, v, boundary)
  local _t = type(v)

  tprintf(r, "--%s\r\n", boundary)
  if _t == "string" then
    section_header(r, k, {})
  elseif _t == "table" then
    assert(v.data, "invalid input")
    local extra = {
      filename = v.filename or v.name,
      content_type = v.content_type or v.mimetype
        or "application/octet-stream",
      content_transfer_encoding = v.content_transfer_encoding
        or "binary",
    }
    section_header(r, k, extra)
  else
    error(string.format("unexpected type %s", _t))
  end
end

local function encode_header_as_source(k, v, boundary, ctx)
  local r = {}
  encode_header_to_table(r, k, v, boundary, ctx)
  local s = table.concat(r)
  if ctx then
    ctx.headers_length = ctx.headers_length + #s
  end
  return ltn12.source.string(s)
end

local function data_len(d)
  local _t = type(d)

  if _t == "string" then
    return string.len(d)
  elseif _t == "table" then
    if type(d.data) == "string" then
      return string.len(d.data)
    end
    if d.len then return d.len end
    error("must provide data length for non-string datatypes")
  end
end

local function content_length(t, boundary, ctx)
  local r = ctx and ctx.headers_length or 0
  for k, v in pairs(t) do
    if not ctx then
      local tmp = {}
      encode_header_to_table(tmp, k, v, boundary)
      r = r + #table.concat(tmp)
    end
    r = r + data_len(v) + 2 -- `\r\n`
  end
  return r + #boundary + 6 -- `--BOUNDARY--\r\n`
end

local function get_data_src(v)
  local _t = type(v)
  if v.source then
    return v.source
  elseif _t == "string" then
    return ltn12.source.string(v)
  elseif _t == "table" then
    _t = type(v.data)
    if _t == "string" then
      return ltn12.source.string(v.data)
    elseif _t == "table" then
      return ltn12.source.table(v.data)
    elseif _t == "userdata" then
      return ltn12.source.file(v.data)
    elseif _t == "function" then
      return v.data
    end
  end
  error("invalid input")
end

local function set_ltn12_blksz(sz)
  assert(type(sz) == "number", "set_ltn12_blksz expects a number")
  ltn12.BLOCKSIZE = sz
end
mp.set_ltn12_blksz = set_ltn12_blksz

local function source(t, boundary, ctx)
  local sources, n = {}, 1
  for k, v in pairs(t) do
    sources[n] = encode_header_as_source(k, v, boundary, ctx)
    sources[n+1] = get_data_src(v)
    sources[n+2] = ltn12.source.string("\r\n")
    n = n + 3
  end
  sources[n] = ltn12.source.string(string.format("--%s--\r\n", boundary))
  return ltn12.source.cat(table.unpack(sources))
end
mp.source = source

function mp.encode(t, boundary)
  boundary = boundary or mp.boundary()
  local r = {}
  assert(ltn12.pump.all(
    (source(t, boundary)),
    (ltn12.sink.table(r))
  ))
  return table.concat(r), boundary
end

return mp
