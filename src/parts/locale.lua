local Locale = {
  list = {
    'en',
    'ru'
  },
  main = 'en',

  __newindex = function()end -- ro
}
Locale.__index = Locale

function Locale:get(cat, k, lang)
  assert(cat, 'Give category')
  assert(k,   'Give key')
  lang = lang or self.main

  local v = self[lang][cat][k]
  if not v then
    return self[self.main][cat][k]
  else return v end
end

return function(C)
  local json = require 'etc.json'

  for i = 1, #Locale.list do
    local n = Locale.list[i]
    local f = io.open(('src/locales/%s.json'):format(n))
    Locale[n] = json.decode(f:read 'a')
  end

  C.locale = setmetatable({}, Locale)
end
