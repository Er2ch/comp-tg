﻿function table.indexOf(t, w)
  local i = {}
  for k,v in pairs(t) do i[v] = k end
  return i[w]
end

function table.find(t, w)
  local i
  for k,v in pairs(t) do
    if v == w then
      i = k
      break
    end
  end
  return i
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
  local a = {}
  for k, v in pairs(C.cmds) do
    if not v.private then
      table.insert(a, {
        command = k,
        description = (v.args and v.args .. ' - ' or '') .. v.desc or 'no description'
      })
    end
  end
  api:setMyCommands(a)
end