local config = require 'config'

local Core = {
  db = require 'db' ('db'), -- db with name db
  tg = require 'core',
  tools = tools,
  config = config,
  cmds = {},
}
local tg = Core.tg

function Core:load(what)
  local c = config[what]
  local s = #c
  for i = 1, s do
    local v = c[i]

    print(('Loading %s (%d / %d) %s...'):format(what:sub(0, -2), i, s, v))
    -- Lint
    if pcall(require, what ..'.'.. v) then
      local a=require(what ..'.'.. v)
      if     what == 'events' then self.api:on(v, a)
      elseif what == 'cmds'   then self.cmds[v] = a
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

  self.api._ev = function(s, t, i, name, ...)
    -- print(s, t, i, name)
    self:ev(t, i, name, s, ...)
  end

  self:load 'events'

  self.api:login(config.token, function()
    print('Logged on as @' .. self.api.info.username)
    self.config.token = nil
    self.api:emit('ready')
  end)

  print 'Done!'

  local offs, o = 0
  self.t = os.time()
  self.api.runs = true
  while self.api.runs do
    o = self.api:_getUpd(1, offs, 0)
    offs = o and o or offs

    if os.time() - self.t >= 60 * 5 then
      self.t = os.time()
      print 'saving...'
      self.db:save()
    end
  end
  self.api:getUpdates(1, offs, 0)
end

Core:init()
