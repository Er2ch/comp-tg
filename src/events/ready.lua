function table.indexOf(t, w)
  local i = {}
  for k,v in pairs(t) do i[v] = k end
  return i[w]
end

function table.find(t, w)
  for _,v in pairs(t) do
    if v == w then return v end
  end
end

function table.findV(t, w)
  local b
  for _,v in pairs(t) do
    for k,x in pairs(w) do
      if x ~= v[k] then b=1; break end
    end
    if b then b = nil
    else return v end
  end
end

function dump(t, d)
  if not tonumber(d) or d < 0 then d = 0 end
  local c = ''
  for k,v in pairs(t) do
    if type(v) == 'table' then v = '\n' .. dump(v, d + 1) end
    c = c .. string.format('%s%s = %s\n', (' '):rep(d), k, v)
  end
  return c
end

return function(C, api)
  C:load 'cmds'
  local a
  for _, lang in pairs(C.locale.list) do
    a = {}
    for k, v in pairs(C.cmds) do
      if not (v.private or v.hide) then
        local cmd = C.locale:get('cmds', k, lang) or {}
        table.insert(a, {
          command = k,
          description = (cmd.args and cmd.args .. ' - ' or '') .. (cmd.desc or C.locale:get('cmds', 'not_des'))
        })
      end
    end
    api:setMyCommands(a, lang)
  end

--[[
  a = {'levels', }
  for i = 1, #a do
    if not C.db[a[i] ] then C.db[a[i] ] = {} end
  end
--]]
end
