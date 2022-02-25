return function(C, api, msg)
  -- надоели эхать
  if msg.text
  and msg.text:match '[Ээ]+[Хх]+' then
    C.api:reply(msg, msg.text
      :gsub('[Ээ]+[Хх]+', 'хуех')
    ,nil)
  end
end
