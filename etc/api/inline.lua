--[[ Inline query library
  -- (c) Er2 2021 <er2@dismail.de>
  -- Zlib License
--]]

local inline = {}
inline.__index = inline -- Make class

function inline.query(id, from, q, off, ct, loc)
  return {
    id = tostring(id),
    from = from,
    query = q,
    offset = off,
    chat_type = ct,
    location = loc,
  }
end

function inline.result(type, id, ...)
  type = tostring(type)
  local t = setmetatable({
    type = type,
    id = tostring(tonumber(id) or 1),
  }, inline)
  local a = {...}
  if t.type == 'article' then t.title, t.url, t.hide_url, t.description = table.unpack(a)

  elseif t.type == 'photo' then
    t.photo_url, t.photo_width, t.photo_height, t.title, t.description,
    t.caption, t.parse_mode, t.caption_entities
      = table.unpack(a)

  elseif t.type == 'gif' or t.type == 'mpeg4_gif' then
    local url, width, height, duration
    url, width, height, duration, t.title, t.caption, t.parse_mode, t.caption_entities
      = table.unpack(a)

    if t.type == 'gif' then
      t.gif_url, t.gif_width, t.gif_height, t.gif_duration
      = url, width, height, duration
    else
      t.mpeg4_url, t.mpeg4_width, t.mpeg4_height, t.mpeg4_duration
      = url, width, height, duration
    end

  elseif t.type == 'video' then
    t.video_url, t.mime_type, t.title, t.caption, t.parse_mode,
    t.caption_entities, t.video_width, t.video_height, t.video_duration, t.description
      = table.unpack(a)

  elseif t.type == 'audio' or t.type == 'voice' then
    t.title, t.caption, t.parse_mode, t.caption_entities = table.unpack(a, 2)

    if t.type == 'audio' then
      t.audio_url, t.performer, t.audio_duration = a[1], a[6], a[7]
    else
      t.voice_url, t.voice_duration = a[1], a[6]
    end

  elseif t.type == 'document' then
    t.title, t.caption, t.parse_mode, t.caption_entities, t.document_url,
    t.mime_type, t.description = table.unpack(a)

  elseif t.type == 'location' or t.type == 'venue' then
    t.latitude, t.longitude, t.title = table.unpack(a, 1, 3)

    if t.type ~= 'venue' then
      t.horizontal_accurancy, t.live_period, t.heading, t.proximity_alert_radius
      = table.unpack(a, 4, 7)
    else
      t.address, t.foursquare_id, t.foursquare_type, t.google_place_id, t.google_place_type
      = table.unpack(a, 4, 8)
    end

  elseif t.type == 'contact' then
    t.phone_number, t.first_name, t.last_name, t.vcard,
    t.reply_markup, t.input_message_content
      = table.unpack(a)

  elseif t.type == 'game' then t.game_short_name = a[1]
  end

  return t
end

function inline:thumb(url, width, height, mime)
  if self.type == 'audio'
  or self.type == 'voice'
  or self.type == 'game'
  then return self end

  self.thumb_url = tostring(url)

  if  width and height and (
     self.type == 'article'
  or self.type == 'document'
  or self.type == 'contact'
  or self.type == 'location'
  or self.type == 'venue'
  ) then
    self.thumb_width  = tonumber(width)
    self.thumb_height = tonumber(height)
  end

  if mime and (
     self.type == 'gif'
  or self.type == 'mpeg4_gif'
  ) then self.thumb_mime_type = mime end

  return self
end

function inline:keyboard(...)
  if not self.type then return self end
  local k = {}

  for _, v in pairs {...} do
    if type(v) == 'table' then
      table.insert(k, v)
    end
  end
  self.reply_markup = k

  return self
end

-- Author itself not understands why this funciton needed
-- so not recommends to use it
function inline:messCont(a)
  if self.type == 'game' or self.type == 'article' then
    self.input_message_content = a
  end
  return self
end

function inline:answer(id, res, ctime, per, noff, pmt, pmp)
   print(dump(res))
  if res.id then res = {res} end 
  return self:request('answerInlineQuery', {
    inline_query_id = id,
    results = res,
    cache_time = ctime,
    is_personal = per,
    next_offset = noff,
    switch_pm_text = pmt,
    switch_pm_parameter = pmp,
  })
end

return function(api)
  local self = setmetatable({
    request = function(_, ...) api:request(...) end
  }, inline)
  return self
end
