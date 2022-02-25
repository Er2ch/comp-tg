local reg = {
  {'эх', 'хуех'}, -- надоели эхать
  {'мета', 'хуета'},
  {'meta', 'xueta'},
  {'цукерберг', 'цукерхуй'},
  {'zuckerberg', 'zuckerhui'},
  {'whatsapp', 'вадзад'},
  {'TikTok', 'деградация'},
  {'.*че%?*$', 'пиши ё, грамотей'},
  {'.*чё%?*$', 'ничё'}
}

return function(C, api, msg)
  if msg.text then
    local t = msg.text
    for _, v in pairs(reg) do
      t = t:gsub(v[1], v[2])
    end
    if msg.text ~= t
    then api:reply(msg, t)
    end
  end
end
