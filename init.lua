local config = require 'config'

local Core = {
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
  self.api = tg(config.token)
  self.config.token = nil
  
  print('Logged on as @' .. self.api.info.username)
  print 'Client initialization...'

  self:load 'events'

  print 'Done!'
  self.api:run()
end

Core:init()