
table.indexOf = (t, w) ->
  i = {}
  for k, v in pairs t
    i[v] = k
  i[w]

table.find = (t, w) ->
  for _, v in pairs t
    return v if v == w

table.findV = (t, w) ->
  b = nil
  for _, v in pairs t
    for k, x in pairs w
      if x ~= v[k]
        b = 1
        break
    if b then b = nil -- continue
    else return v

string.escp = (s) ->
  s\gsub '[%^%$%%%(%)%.%[%]%*%+%-%?]', '%%%0'

export dump = (t, d) ->
  d = 0 if not tonumber(d) or d < 0
  c = ''
  for k, v in pairs t
    if type(v) == 'table'
      v = '\n'.. dump v, d + 1

    elseif type(v) == 'userdata'
      v = '<USERDATA>'

    c ..= ('%s%s = %s\n')\format (' ')\rep d, k, v
  c

(api) =>
  @\load 'cmds'

  for _, lang in pairs @locale.list
    a = {}
    for k, v in pairs @cmds
      if not (v.private or v.hide)
        cmd = @locale\get 'cmds', k, lang or {}
        table.insert a, {command: k,
          description: (cmd.args and cmd.args .. ' - ' or '') .. (cmd.desc or @locale\get 'cmds', 'not_des')
        }
    api\setMyCommands a, lang
  return
