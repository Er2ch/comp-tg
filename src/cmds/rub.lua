-- It uses data from central bank of Russia
--- and external service to get json from xml
-- Privacy and security is unknown

local rub = {
  url = 'https://api.factmaven.com/xml-to-json/?xml='
    .. 'https://www.cbr.ru/scripts/XML_daily.asp',

  tools = require 'etc.api.tools',
}

function rub:course(wants)
  local resp, succ = self.tools._req(self.url, 'GET')
  if not succ then return 'err' end
  resp = self.tools.json.decode(resp or '{}')

  resp = resp.ValCurs
  table.insert(resp.Valute, {
    ID = 'R01000',
    NumCode = '001',
    CharCode = 'RUB',
    Nominal = 1,
    Name = 'Российский рубль',
    Value = '1'
  })
  local uah = table.findV(resp.Valute, {CharCode = 'UAH'})
  table.insert(resp.Valute, {
    ID = 'R02000',
    NumCode = '200',
    CharCode = 'SHT',
    Nominal = 1,
    Name = 'Штаны',
    Value = ('%f'):format(tonumber(uah.Value:gsub(',', '.'), nil) / uah.Nominal * 40)
  })

  wants = type(wants) == 'table' and wants or {}
  local r, founds = {}, {}

  for i = 1, #resp.Valute do
    local v = resp.Valute[i]
    if table.find(wants, v.CharCode) then
      table.insert(founds, v.CharCode)
      table.insert(r, ('%d %s (%s) - %f ₽'):format(v.Nominal, v.Name, v.CharCode, v.Value:gsub(',', '.')))
    end
  end

  return r, resp.Date, founds
end

return {
  run = function(C, msg)
    local wants = {'USD', 'EUR', table.unpack(msg.args)}
    for i = 1, #wants do wants[i] = wants[i]:upper() end -- uppercase

    local v, d, f = rub:course(wants)
    if v == 'error' then
      return C.api:reply(msg, C.locale:get('error', 'req_err', msg.l))
    end

    local nf = {}
    for _, i in pairs(wants) do
      if not table.find(f, i) then table.insert(nf, i) end
    end

    local s = msg.loc.cur:format(d, table.concat(v, '\n'))
    if #nf > 0 then s = s .. msg.loc.notf .. table.concat(nf, ',') end

    C.api:reply(msg, s .. msg.loc.prov)
  end
}
