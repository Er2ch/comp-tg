local tg = require 'etc.api'

return function(Core)
  local self = Core
  
  self.api = tg { norun = true }
  self.cmds = {}

  print 'Client initialization...'

  function Core._ev(ev, ...) self:ev(...) end
  function self.api._ev(_, t, i, n, ...)
    self._ev(_, t, i, n, self.api, ...)
  end

  self:load 'events'

  self.api:login(self.config.token, function()
    print('Logged on as @' .. self.api.info.username)
    self.config.token = nil
    self.api:emit 'ready'
  end)

  local offs, o = 0
  self.api.runs = true
  self:on('ready', function()
    while self.api.runs do
      self:emit 'tick'

      o = self.api:_getUpd(1, offs, 0)
      offs = o and o or offs
    end
    self.api:getUpdates(1, offs, 0)
  end)
end
