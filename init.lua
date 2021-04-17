local config = require 'config'

local Core = {
  db = require 'db.db' ('db'),
  tg = require 'tg',
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
    if not pcall(require, what .. '.' .. v) then print 'fail'; goto f end

    local a = require(what .. '.' .. v)
    if what == 'events' then
      self.api['on' .. v:sub(1, 1):upper() .. v:sub(2)] = function(...)
        local succ = pcall(a, self, ...)
        if not succ then print('event ' .. v .. ' was failed') end
      end
    elseif what == 'cmds' then self.cmds[v] = a
    end
    ::f::
  end
  print(('Loaded %d %s'):format(s, what))
end

function Core:init()
  self.api = tg {norun = true}

  print 'Client initialization...'

  self:load 'events'

  self.api:login(config.token, function()
    print('Logged on as @' .. self.api.info.username)
    self.config.token = nil
    self.api:onReady()
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