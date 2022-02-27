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

(api, msg) =>
  if msg.text
    msg.text = utf8.lower ' '.. msg.text ..' '
    t = msg.text
    for _, v in pairs reg
      t = utf8.gsub t, '%s+'.. v[1] ..'%s+', ' '.. v[2] ..' '

    api\reply msg, t if t ~= msg.text
  elseif msg.sticker
    if msg.sticker.file_unique_id == 'AgADwAADcpO1DQ'
      api\reply msg, 'редебало'
  return
