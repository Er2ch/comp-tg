reg = {
  {'эх+%.*',          'хуех'} -- надоели эхать
  {'мета',            'хуета'}
  {'meta',            'xueta'}
  {'цукерберг',       'цукерхуй'}
  {'zuckerberg',      'zuckerhui'}
  {'wh?atsapp?',      'вадзад'}
  {'в[ао][тсц]+апп?', 'вадзад'}
  {'tiktok',          'деградация'}
  {'ч[ую]ма',         'капитализм'}
  {'минет',           'еблет'}
  {'еблет',           'пакет'}
  {'да',              'пизда'}
  {'нет',             'минет'}
  {'че%?*',           'пиши ё, грамотей'}
  {'чё%?*',           'ничё'}
}

stick = {
  {
    'AgADwAADcpO1DQ'
    'редебало'
    'CAACAgIAAx0CUY2umQACFItiHHUg6w_MPu6Vs8k76cwn4OIHNQACwAADcpO1DVbNTDlmHOWMIwQ'
  }
}

(api, msg) =>
  if msg.text
    msg.text = utf8.lower ' '.. msg.text ..' '
    t = msg.text
    for _, v in pairs reg
      t = utf8.gsub t, '%s+'.. v[1] ..'%s+', ' '.. v[2] ..' '

    api\reply msg, t if t ~= msg.text
  elseif msg.sticker
    for k, v in pairs stick
      if msg.sticker.file_unique_id == v[1]
        if math.random! <= 0.5
          api\reply msg, v[2]
        else api\sendSticker msg, v[3] --, _, _, _, msg.message_id

  return
