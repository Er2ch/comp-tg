prind = (...) ->
  t = {...}
  s = ''
  for i = 1, #t
    if i > 1
      s ..= '\t'
    s ..= tostring t[i] or 'nil'
  s .. '\n'

env =
  assert: assert
  error: error
  ipairs: ipairs
  pairs: pairs
  next: next
  tonumber: tonumber
  tostring: tostring
  type: type
  pcall: pcall
  xpcall: xpcall

  math: math
  string: string
  table: table

  dump: dump

{
  private: true
  run: (msg, owner) =>
    s = ''
    t =
      msg: msg
      print: (...) -> s ..= prind ...

      C:   owner and @    or nil
      api: owner and @api or nil

    for k, v in pairs env
      t[k] = v

    e, err = load @api.unparseArgs(msg.args), 'eval', 'bt', t

    xpcall (->
      error err if err
      e = tostring e! or '...'
    ), (err) -> e = err

    s ..= '\n'.. e
    s = s\gsub @api.token\escp!, '<TOKEN>'

    @api\reply msg, s
    return
}
