local config = require 'config'

local Core = {
  tg = require 'etc.api',
  config = config,
  cmds = {},

  _ev_ = {}, -- :evil:
}
local tg = Core.tg

Core = (require 'etc.events')(Core) -- add events

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
      elseif what == 'core'   then a(self)
      end
    else print 'fail' end
  end
  print(('Loaded %d %s'):format(s, what))
end

function Core:ev(t, i, name, ...)
  local v = t[i]
  if v.name == name then
    local succ = pcall(v.fn, self, ...)
    if not succ then print('event "' .. name .. '" was failed') end
    if v.type == 'once' then table.remove(t, i) end
  end
end

function Core:init()
  self.api = tg {norun = true}

  print 'Client initialization...'

  function Core._ev(ev, ...) self:ev(...) end
  function self.api._ev(ev, t, i, n, ...)
    self._ev(ev, t, i, n, self.api, ...)
  end

  self:load 'events'
  self:load 'core'

  self.api:login(config.token, function()
    print('Logged on as @' .. self.api.info.username)
    self.config.token = nil
    self.api:emit 'ready'
  end)

  self:emit 'init'
  print 'Done!'

  local offs, o = 0
  self.t = os.time()
  self.api.runs = true
  while self.api.runs do
    self:emit 'tick'
    
    o = self.api:_getUpd(1, offs, 0)
    offs = o and o or offs
  end
  self.api:getUpdates(1, offs, 0)
end

Core:init()
