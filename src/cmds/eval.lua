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
  run = function(C, msg, owner)
    local s = ''
    local t = {
      msg = msg,
      print = function(...) s = s .. prind(...) end,

      C = owner and C or nil,
      api = owner and C.api or nil,
    }
    for k,v in pairs(env) do t[k] = v end
    local e, err = load(C.api.unparseArgs(msg.args), 'eval', 'bt', t)
    xpcall(function()
      if err then error(err) end
      e = tostring(e() or '...')
    end, function(err) e = err end)
    s = s ..'\n'.. e
    s = s:gsub(C.api.token:escp(), '<TOKEN>')
    C.api:reply(msg, s)
  end
}
