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
    t = ''
    for _, v in pairs reg
      if utf8.match msg.text, '%s+'.. v[1] ..'%s+'
        t ..= "#{v[2]} "

    api\reply msg, t if t ~= ''
  return
