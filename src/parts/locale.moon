Locale =
  __newindex: -> -- ro

  list: {
    'en'
    'ru'
  }
  main: 'en'

  get: (cat, k, lang) =>
    assert cat, 'Give category'
    assert k,   'Give key'
    lang or= @main

    v = (@[lang] or {})[cat]
    if not v
      @[@main][cat][k] or {}
    else v[k] or {}

Locale.__index = Locale

(C) ->
  json = require 'etc.json'

  for i = 1, #Locale.list
    n = Locale.list[i]
    f = io.open "src/locales/#{n}.json"
    Locale[n] = json.decode f\read 'a'

  C.locale = setmetatable {}, Locale
