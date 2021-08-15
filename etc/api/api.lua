--[[ API Library
  -- (c) Er2 2021 <er2@dismail.de>
  -- Zlib License
--]]

local tools  = require 'etc.api.tools'
local json   = require 'etc.json'
local events = require 'etc.events'
local api    = {
  request    = function(s, ...) return tools.request(s.token, ...) end
}
api.__index = api -- Make class
events(api)       -- inheritance

-- parse arguments
local function argp(cid, rmp, pmod, dwp)
  return
    type(cid) == 'table' and cid.chat.id or cid,
    type(rmp) == 'table' and json.encode(rmp) or rmp,
    (type(pmod) == 'boolean' and pmod == true) and 'MarkdownV2' or pmod,
    dwp == nil and true or dwp
end

-- Getters without params

function api:getMe() return self:request 'getMe' end
function api:getMyCommands() return self:request 'getMyCommands' end

-- Getters with params

function api:getChat(cid) return self:request('getChat', {chat_id = cid}) end

-- Setters

function api:send(msg, txt, pmod, dwp, dnot, rtmid, rmp)
  msg, rmp, pmod, dwp = argp(msg, rmp, pmod, dwp)

  if txt and #txt >= 4096 then
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
  _, rmp, pmod, dwp = argp(msg, rmp, pmod, dwp)
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

function api:sendPhoto(cid, f, cap, pmod, dnot, rtmid, rmp)
  cid, rmp, pmod = argp(cid, rmp, pmod)
  return self:request('sendPhoto', {
    chat_id = cid,
    caption = cap,
    parse_mode = pmod,
    disable_notification = dnot,
    reply_to_message_id = rtmid,
    reply_markup = rmp,
  }, { photo = f })
end

function api:sendDocument(cid, f, cap, pmod, dnot, rtmid, rmp)
  cid, rmp, pmod = argp(cid, rmp, pmod)
  return self:request('sendDocument', {
    chat_id = cid,
    caption = cap,
    parse_mode = pmod,
    disable_notification = dnot,
    reply_to_message_id = rtmid,
    reply_markup = rmp,
  }, { document = f })
end

function api:sendPoll(cid, q, opt, anon, ptype, mansw, coptid, expl, pmode, oper, cdate, closed, dnot, rtmid, rmp)
  cid, rmp, pmode = argp(cid, rmp, pmode)
  opt = type(opt) == 'string' and opt or json.encode(opt)
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

function api:answerCallback(id, txt, alrt, url, ctime)
  return self:request('answerCallbackQuery', {
    callback_query_id = id,
    text = txt,
    show_alert = alrt,
    url = url,
    cache_time = ctime,
  })
end

function api:setMyCommands(cmds)
  return self:request('setMyCommands', { commands = json.encode(cmds) })
end

return api
