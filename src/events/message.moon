reg = {
  {'эх',         'хуех'} -- надоели эхать
  {'мета',       'хуета'}
  {'meta',       'xueta'}
  {'цукерберг',  'цукерхуй'}
  {'zuckerberg', 'zuckerhui'}
  {'whatsapp',   'вадзад'}
  {'tiktok',     'деградация'}
  {'.*че%?*$',   'пиши ё, грамотей'}
  {'.*чё%?*$',   'ничё'}
}

(api, msg) =>
  if msg.text
    msg.text = utf8.lower msg.text
    t = ''
    for _, v in pairs reg
      if msg.text\match v[1]
        t ..= "#{v[2]} "

    api\reply msg, t if t ~= ''
  return
