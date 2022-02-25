local reg = {
  {'эх',         'хуех'}, -- надоели эхать
  {'мета',       'хуета'},
  {'meta',       'xueta'},
  {'цукерберг',  'цукерхуй'},
  {'zuckerberg', 'zuckerhui'},
  {'whatsapp',   'вадзад'},
  {'tiktok',     'деградация'},
  {'.*че%?*$',   'пиши ё, грамотей'},
  {'.*чё%?*$',   'ничё'}
}

return function(C, api, msg)
  if msg.text then
    msg.text = utf8.lower(msg.text)
    local t = ''
    for _, v in pairs(reg) do
      if msg.text:match(v[1])
      then t = t.. v[2] ..' '
      end
    end
    if t ~= ''
    then api:reply(msg, t) end
  end
end
