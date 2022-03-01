{
  private: true
  run: (msg) =>
    cat, sub, arg = table.unpack msg.args
    if not (cat and sub)
      return @api\reply msg, '/reload cmds ping'

    path = "src.#{cat}.#{sub}"

    @api\off package.loaded[path]
    package.loaded[path] = nil

    if arg == '-off'
      @api\reply msg, 'Turned off'

    else
      suc, m = pcall require, path
      if not suc then return @api\reply msg, "Reload failed. #{m}"
      switch cat
        when 'events' then @api\on sub, m
        when 'cmds'   then @cmds[sub] = m
        else m @
      @api\reply msg, "Reloaded. #{m}"

    return
}
