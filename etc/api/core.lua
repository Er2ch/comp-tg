--[[ Core file
  -- (c) Er2 2021 <er2@dismail.de>
  -- Zlib License
--]]

local tools = require 'etc.api.tools'
local api = require 'etc.api.api'
api.__index = api

function api:_ev(t, i, name, ...)
  local v = t[i]
  if v.name == name then
    v.fn(self, ...)
    if v.type == 'once' then table.remove(t, i) end
  end
end

-- UPDATES --
function api:getUpdates(lim, offs, tout, allowed)
  allowed = type(allowed) == 'table' and tools.json.encode(allowed) or allowed
  return self:request('getUpdates', {
    timeout = tout,
    offset = offs,
    limit = lim,
    allowed_updates = allowed
  })
end

local function receiveUpdate(self, update)
  if update then self:emit('update', update) end

  if update.message then
    local msg = update.message
    local cmd, to = tools.fetchCmd(msg.text or '')
    if cmd and (not to or to == self.info.username) then
      -- need /cmd@bot in groups
      if (msg.chat.type == 'group' or msg.chat.type == 'supergroup')
       and not to then return end

      local args = {}
      txt = msg.text:sub(#cmd + #(to or {}) + 3)
      for s in msg.text:gmatch '%S+' do table.insert(args, s) end

      msg.cmd  = cmd
      msg.args = args

      return self:emit('command', msg)
    elseif cmd then return end

    self:emit('message', msg)

  elseif update.edited_message then
    self:emit('messageEdit', update.edited_message)

  elseif update.channel_post then self:emit('channelPost', update.channel_post)
  elseif update.edited_channel_post then self:emit('channelPostEdit', update.edited_channel_post)

  elseif update.poll then self:emit('poll', update.poll)
  elseif update.poll_answer then self:emit('pollAnswer', update.poll_answer)

  elseif update.callback_query then self:emit('callbackQuery', update.callback_query)
  elseif update.inline_query then self:emit('inlineQuery', update.inline_query)
  elseif update.shipping_query then self:emit('shippingQuery', update.shipping_query)
  elseif update.pre_checkout_query then self:emit('preCheckoutQuery', update.pre_checkout_query)

  elseif update.chosen_inline_result then self:emit('inlineResult', update.chosen_inline_result)
  end
end

function api:_getUpd(lim, offs, ...)
  local u, ok = self:getUpdates(lim, offs, ...)
  if not ok or not u or (u and type(u) ~= 'table') or not u.result then return end
  for _, v in pairs(u.result) do
    offs = v.update_id + 1
    receiveUpdate(self, v)
  end
  return offs
end

function api:_loop(lim, offs, ...)
  while api.runs do
    local o = self:_getUpd(lim, offs, ...)
    offs = o and o or offs
  end
  self:getUpdates(lim, offs, ...)
end

-- RUN --
function api:run(lim, offs, tout, al)
  lim = tonumber(lim) or 1
  offs = tonumber(offs) or 0
  tout = tonumber(tout) or 0

  self.runs = true
  self:emit('ready')

  self.co = coroutine.create(api._loop)
  coroutine.resume(self.co, self, lim, tout, offs, al)
end

function api:destroy() self.runs = false end

function api:login(token, thn)
  self.token = assert(token or self.token, 'Provide token!')

  repeat
    local r, o = self:getMe()
    if o and r then self.info = r end
  until (self.info or {}).result

  self.info = self.info.result
  self.info.name = self.info.first_name

  if type(thn) == 'function' then thn(self) end

  if not self.nr then self:run() end
end

return function(opts)
  if not token or type(token) ~= 'string' then token = nil end

  local self = setmetatable({}, api)
  if type(opts) == 'table' then
    if opts.token then self.token = opts.token end
    if opts.norun then self.nr = true end
  end

  return self
end
