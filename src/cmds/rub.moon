-- It uses data from central bank of Russia
--- and external service to get json from xml
-- Privacy and security is unknown

rub =
  url: 'https://api.factmaven.com/xml-to-json/?xml=https://www.cbr.ru/scripts/XML_daily.asp'

  tools: require 'etc.api.tools'

  pat: '%d %s (%s) - %f ₽'

  getPat: (val) =>
    @pat\format val.Nominal, val.Name, val.CharCode, val.Value\gsub ',', '.'

  course: (wants) =>
    res, suc = @tools._req @url, 'GET'
    return 'err' if not suc
    res = @tools.json.decode res or '{}'
    res = res.ValCurs
    return 'err' if not res

    table.insert res.Valute, {
      ID: 'R01000'
      NumCode: '001'
      CharCode: 'RUB'
      Nominal: 1
      Name: 'Российский рубль',
      Value: '1'
    }
    uah = table.findV res.Valute, CharCode: 'UAH'
    table.insert res.Valute, {
      ID: 'R02000'
      NumCode: '200'
      CharCode: 'SHT'
      Nominal: 1
      Name: 'Штаны'
      Value: ('%f')\format tonumber(uah.Value\gsub(',', '.'), nil) / uah.Nominal * 40
    }

    wants = type(wants) == 'table' and wants or {}
    r, founds = {}, {}

    if table.find wants, 'ALL'
      for _, v in pairs res.Valute
        table.insert r, @getPat v
      return r, res.Date, wants

    for _, v in pairs res.Valute
      if table.find wants, v.CharCode
        table.insert founds, v.CharCode
        table.insert r, @getPat v

    return r, res.Date, founds

{
  run: (msg) =>
    wants = {'USD', 'EUR', table.unpack msg.args}
    for i = 1, #wants
      wants[i] = wants[i]\upper!

    v, d, f = rub\course wants
    if v == 'err'
      return @api\reply msg, @locale\get 'error', 'req_err', msg.l

    nf = {}
    for _, i in pairs wants
      table.insert nf, i if not table.find f, i

    s = msg.loc.cur\format d, table.concat v, '\n'
    if #nf > 0
      s = s .. msg.loc.notf.. table.concat nf, ','

    @api\reply msg, s.. msg.loc.prov
    return
}
