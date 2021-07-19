--[[ API Library
  -- (c) Er2 2021 <er2@dismail.de>
  -- Zlib License
--]]

local tools =require 'core.tools'
local json = require 'core.json'
local events=require 'core.events'
local api = { _ev_ = {} }
api.__index = api -- Make class

events(api) -- inheritance

function api:request(...) return tools.request(self.token, ...) end

-- Getters without params

function api:getMe() return self:request 'getMe' end
function api:getMyCommands() return self:request 'getMyCommands' end

-- Getters with params

function api:getChat(cid) return self:request('getChat', {chat_id = cid}) end

-- Setters

function api:send(msg, txt, pmod, dwp, dnot, rtmid, rmp)
  rmp = type(rmp) == 'table' and json.encode(rmp) or rmp
  msg = (type(msg) == 'table' and msg.chat and msg.chat.id) and msg.chat.id or msg
  pmod = (type(pmod) == 'boolean' and pmod == true) and 'markdown' or pmod
  if dwp == nil then dwp = true end

  if txt and #txt > 4096 then
    txt = txt:sub(0, 4092) .. '...'
  end

  return self:request('sendMessage', {
    chat_id = msg,
    text = txt,
    parse_mode = pmod,
    disable_web_page_preview = dwp,
    disable_notification = dnot,
    reply_to_message_id = rtmid,
    reply_markup = rmp,
  })
end

function api:reply(msg, txt, pmod, dwp, rmp, dnot)
  if type(msg) ~= 'table' or not msg.chat or not msg.chat.id or not msg.message_id then return false end
  rmp = type(rmp) == 'table' and json.encode(rmp) or rmp
  pmod = (type(pmod) == 'boolean' and pmod == true) and 'markdown' or pmod

  return self:request('sendMessage', {
    chat_id = msg.chat.id,
    text = txt,
    parse_mode = pmod,
    disable_web_page_preview = dwp,
    disable_notification = dnot,
    reply_to_message_id = msg.message_id,
    reply_markup = rmp,
  })
end

function api:forward(cid, frcid, mid, dnot)
  return self:request('forwardMessage', {
    chat_id = cid,
    from_chat_id = frcid,
    disable_notification = dnot,
    message_id = mid,
  })
end

function api:sendPoll(cid, q, opt, anon, ptype, mansw, coptid, expl, pmode, oper, cdate, closed, dnot, rtmid, rmp)
  opt = type(opt) == 'string' and opt or json.encode(opt)
  rmp = type(rmp) == 'table' and json.encode(rmp) or rmp
  anon = type(anon) == 'boolean' and anon or false
  mansw = type(mansw) == 'boolean' and mansw or false
  return self:request('sendPoll', {
    chat_id = cid,
    question = q,
    options = opt,
    is_anonymous = anon,
    type = ptype,
    allows_multiple_answers = mansw,
    correct_option_id = coptid,
    explanation = expl,
    explanation_parse_mode = pmode,
    open_period = oper,
    close_date = cdate,
    is_closed = closed,
    disable_notification = dnot,
    reply_to_message_id = rtmid,
    reply_markup = rmp,
  })
end

function api:setMyCommands(cmds)
  return self:request('setMyCommands', { commands = json.encode(cmds) })
end

return api
