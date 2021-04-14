-- Core file
--- (c) Er2 <er2@dismail.de>
--- Zlib License

local tools = require 'tg.tools'
local api = require 'tg.api'
api.__index = api -- Make class

-- EVENT PROTOTYPES --
function api.onCommand(_) end
function api.onChannelPost(_) end
function api.onChannelPostEdit(_) end
function api.onMessage(_) end
function api.onMessageEdit(_) end
function api.onInlineResult(_) end
function api.onPoll(_) end
function api.onPollAnswer(_) end
function api.onReady(_) end
function api.onQuery(_) end
function api.onUpdate(_) end

-- UPDATES --
function api:getUpdates(tout, offs, lim, allowed)
  allowed = type(allowed) == 'table' and tools.json.encode(allowed) or allowed
  return self:request('getUpdates', {
    timeout = tout,
    offset = offs,
    limit = lim,
    allowed_updates = allowed
  })
end

local function receiveUpdate(self, update)
  if update then self:onUpdate(update) end

  if update.message then
    local txt = update.message.text
    local cmd, to = tools.fetchCmd(txt)
    if cmd and (not to or to == self.info.username) then
      local args = {}
      txt = txt:sub(#cmd + #(to or {}) + 3)
      for s in txt:gmatch '%S+' do table.insert(args, s) end

      update.message.cmd = cmd
      update.message.args = args
      return self:onCommand(update.message, update.message.chat.type)
    elseif cmd then return end

    self:onMessage(update.message, update.message.chat.type)

  elseif update.edited_message then
    self:onMessageEdit(update.edited_message, update.edited_message.chat.type)

  elseif update.channel_post then self:onChannelPost(update.channel_post)
  elseif update.edited_channel_post then self:onChannelPostEdit(update.edited_channel_post)

  elseif update.poll then self:onPoll(update.poll)
  elseif update.poll_answer then self:onPollAnswer(update.poll_answer)

  elseif update.callback_query then self:onQuery('callback', update.callback_query)
  elseif update.inline_query then self:onQuery('inline', update.inline_query)
  elseif update.shipping_query then self:onQuery('shipping', update.shipping_query)
  elseif update.pre_checkout_query then self:onQuery('preCheckout', update.pre_checkout_query)

  elseif update.chosen_inline_result then self:onInlineResult(update.chosen_inline_result)
  end
end

function api:_loop(lim, tout, offs, al)
  while true do
    local u, ok = self:getUpdates(tout, offs, lim, al)
    if not ok or not u or (u and type(u) ~= 'table') or not u.result then goto f end
    for _, v in pairs(u.result) do
      offs = v.update_id + 1
      receiveUpdate(self, v)
    end
    ::f::
  end
  self:getUpdates(tout, offs, lim, al)
end

-- RUN --
function api:run(lim, tout, offs, al)
  lim = tonumber(lim) or 1
  tout = tonumber(tout) or 0
  offs = tonumber(offs) or 0

  self.runs = true
  self:onReady()

  self.co = coroutine.create(api._loop)
  coroutine.resume(self.co, self, lim, tout, offs, al)
end

function api:destroy() self.runs = false end

return function(token)
  if not token or type(token) ~= 'string' then token = nil end
  local self = setmetatable({}, api)
  self.token = assert(token, 'Provide token!')

  repeat
    local b,a = self:getMe()
    if a then self.info = b end
  until (self.info or {}).result

  self.info = self.info.result
  self.info.name = self.info.first_name
  return self
end