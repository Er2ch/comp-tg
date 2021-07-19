--[[ Events library
  -- (c) Er2 2021 <er2@dismail.de>
  -- Zlib License
--]]

local events = {}
events.__index = events

function events:_add(t, n, f)
  table.insert(self._ev_, {
    type = t,
    name = n,
      fn = f,
  })
end

function events:on(n,f)   self:_add('on', n,f)   end
function events:once(n,f) self:_add('once', n,f) end

function events:_ev(t, i, name, ...)
  local v = t[i]
  if v.name == name then
    v.fn(...)
    if v.type == 'once' then table.remove(t, i) end
  end
end

function events:emit(name, ...)
  local t = self._ev_
  for i = 1, #t do
    local v = t[i] or {}
    if  type(v) == 'table'
    and type(v.type) == 'string'
    and type(v.fn) == 'function'
    then self:_ev(t, i, name, ...) end
  end
end

return function(t) return setmetatable(t, events) end
