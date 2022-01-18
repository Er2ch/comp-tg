local config = require 'config'

local Core = {
  config = config,
  loaded = 0,
}
(require 'etc.events')(Core) -- add events

function Core:load(what)
  local c = config[what]
  local s = #c
  for i = 1, s do
    local v = c[i]

    print(('Loading %s (%d / %d) %s...'):format(what:sub(0, -2), i, s, v))
    -- Lint
    if pcall(require, 'src.'.. what ..'.'.. v) then
      local a=require('src.'.. what ..'.'.. v)
      if     what == 'events' then self.api:on(v, a)
      elseif what == 'cmds'   then self.cmds[v] = a
      elseif what == 'parts'  then a(self)
      end
    else print 'fail' end
  end
  print(('Loaded %d %s'):format(s, what))
  self.loaded = os.time()
end

function Core:ev(t, i, name, ...)
  local v = t[i]
  if v.name == name then
    local succ, err = pcall(v.fn, self, ...)
    if not succ then
      print('event "' .. name .. '" was failed')
      print(err)
    end
    if v.type == 'once' then table.remove(t, i) end
  end
end

function Core:init()
  self:load 'parts'

  print 'Done!'
  self:emit 'ready'
end

function Core:stop()
  self.api:destroy()
  print 'Stopped'
  print('Uptime: '.. os.time() - self.loaded.. ' seconds')
end

Core:init()
