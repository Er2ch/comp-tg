local function prind(...)
  local t = {...}
  local s = ''
  for i = 1, #t do
    if i > 1 then s = s..'\t' end
    s = s .. tostring(t[i] or 'nil')
  end
  return s .. '\n'
end

local env = {
  assert = assert,
  error = error,
  ipairs = ipairs,
  pairs = pairs,
  next = next,
  tonumber = tonumber,
  tostring = tostring,
  type = type,
  pcall = pcall,
  xpcall = xpcall,

  math = math,
  string = string,
  table = table,

  dump = dump,
}

return {
  private = true,
  args = '<code>',
  desc = 'evaluates code',
  run = function(C, msg, owner)
    local s = ''
    local t = {
      msg = msg,
      print = function(...) s = s .. prind(...) end,

      C = owner and C or nil,
      api = owner and C.api or nil,
    }
    for k,v in pairs(env) do t[k] = v end
    local e, err = load(table.concat(msg.args, ' '), 'eval', 't', t)
    xpcall(function()
      if err then error(err) end
      e = tostring(e() or '...')
    end, function(err) e = err end)
    C.api:send(msg, s .. '\n' .. e)
  end
}