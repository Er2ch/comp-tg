local rub = {
  url = 'https://api.factmaven.com/xml-to-json/?xml='
    .. 'https://www.cbr.ru/scripts/XML_daily.asp',
  fmt = function(v, fmt)
    fmt = type(fmt) == 'string' and fmt or '%d %s = %f'
    return fmt:format(v.Nominal, v.Name, v.Value:gsub(',', '.'))
  end
}

function rub:course(wants, fmt)
  local resp, succ = (require'tg.tools').requ(self.url)
  if not succ then
    return {}, '[ошибка]', {}
  end

  resp = resp.ValCurs

  wants = type(wants) == 'table' and wants or {}
  local r, founds = {}, {}
  for i = 1, #resp.Valute do
    local v = resp.Valute[i]
    if table.find(wants, v.CharCode) then
      table.insert(founds, v.CharCode)
      table.insert(r, self.fmt(v, fmt))
    end
  end

  local i = table.find(wants, 'RUB')
  if i then
    table.insert(founds, 'RUB')
    table.insert(r, i, self.fmt({
      Nominal = 1,
      Name = 'Российский рубль',
      Value = '1'
    }, fmt) .. ' :D')
  end

  return r, resp.Date, founds
end

function rub.msg(C, msg)
  local wants = {'USD', 'EUR', table.unpack(msg.args)}
  for i = 1, #wants do wants[i] = wants[i]:upper() end

  local v, d, f = rub:course(wants, '%d %s - %f ₽')
  local nf = {}

  for i = 1, #wants do
    if not table.find(f, wants[i]) then
      table.insert(nf, wants[i])
    end
  end

  local s = 'Курс на ' .. d .. ':\n' .. table.concat(v, '\n')
  if #nf > 0 then s = s .. '\n\n' .. 'Не нашлось: ' .. table.concat(nf, ', ') end

  C.api:reply(msg, s .. '\nДанные от Центробанка России')
end

return {
  args = '[valute]...',
  desc = 'ruble course',
  run = rub.msg
}